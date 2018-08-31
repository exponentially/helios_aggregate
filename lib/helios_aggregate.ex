defmodule Helios.Aggregate do
  @moduledoc """
  Aggregate behaviour.
  """
  defmodule CommandHandlerClauseError do
    @moduledoc """
    Indicates that command handler is not implemented.

    This is runtime exception.
    """
    defexception message: nil, plug_status: :missing_command_hendler

    def exception(opts) do
      aggregate = Keyword.fetch!(opts, :aggregate)
      handler = Keyword.fetch!(opts, :handler)
      params = Keyword.fetch!(opts, :params)

      msg = """
      could not find a matching #{inspect(aggregate)}.#{handler} clause
      to execute command. This typically happens when there is a
      parameter mismatch but may also happen when any of the other
      handler arguments do not match. The command parameters are:

        #{inspect(params)}
      """

      %__MODULE__{message: msg}
    end
  end

  defmodule WrapperError do
    @moduledoc """
    Wraps catched excpetions in aggregate pipeline and rearises it so path of execution
    can easily be spotted in error log.

    This is runtime exception.
    """
    defexception [:context, :kind, :reason, :stack]

    def message(%{kind: kind, reason: reason, stack: stack}) do
      Exception.format_banner(kind, reason, stack)
    end

    @doc """
    Reraises an error or a wrapped one.
    """
    def reraise(%__MODULE__{stack: stack} = reason) do
      :erlang.raise(:error, reason, stack)
    end

    def reraise(_ctx, :error, %__MODULE__{stack: stack} = reason, _stack) do
      :erlang.raise(:error, reason, stack)
    end

    def reraise(ctx, :error, reason, stack) do
      wrapper = %__MODULE__{context: ctx, kind: :error, reason: reason, stack: stack}
      :erlang.raise(:error, wrapper, stack)
    end

    def reraise(_ctx, kind, reason, stack) do
      :erlang.raise(kind, reason, stack)
    end
  end

  alias Helios.Aggregate
  alias Helios.Aggregate.Pipeline.Context

  @type aggregate_id :: String.t()

  defstruct state: nil,
            id: nil,
            version: 0

  @type t :: %Aggregate{
          id: String.t(),
          version: integer,
          state: struct
        }

  @doc """
  Handles execution of the command.
  """
  @callback handle(ctx :: Context.t(), params :: Context.params()) :: Context.t()

  @doc """
  Applies single event to aggregate when replied or after `handle_exec/3` is executed.

  Must return `{:ok, state}` if event is aplied or raise an error if failed.
  Note that events should not be validated here, they must be respected since handle_execute/3
  generated event and already validate it. Also, error has to bi risen in for some odd reason event cannot
  be applied to aggregate.
  """
  @callback apply_event(event :: any, aggregate :: t) :: t | no_return

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      import Helios.Aggregate
      import Helios.Aggregate.Pipeline.Context

      use Helios.Aggregate.Pipeline, opts

      def new() do
        struct(__MODULE__)
      end

      defoverridable [new: 0]
    end
  end

  @doc false
  def plug_init_mode() do
    Application.get_env(:extreme_system, :plug_init_mode, :compile)
  end
end
