defmodule Helios.Aggregate.Pipeline.Context do
  @moduledoc """
  Represent aggregate execution context for single message/command sent to aggregate.
  """

  alias Helios.Aggregate.Pipeline.Context
  alias Helios.Aggregate

  @type opts :: binary | tuple | atom | integer | float | [opts] | %{opts => opts}

  @type aggregate_module :: module
  @type assigns :: %{atom => any}
  @type correlation_id :: String.t() | nil
  @type command :: atom
  @type event :: struct()
  @type events :: nil | event | [event]
  @type halted :: boolean
  @type owner :: pid
  @type params :: map | struct
  @type peer :: pid
  @type plug :: module | atom
  @type plugs :: [(t -> t)]
  @type private :: map
  @type status :: :init | :executing | :commiting | :commited | :success | :failed

  @type t :: %Context{
          aggregate: Aggregate.t(),
          aggregate_module: aggregate_module,
          assigns: assigns,
          correlation_id: correlation_id,
          command: command,
          events: events,
          halted: halted,
          owner: owner,
          params: params,
          peer: peer,
          plugs: plugs,
          private: private,
          retry: integer,
          status: status
        }

  defstruct aggregate: %Aggregate{},
            aggregate_module: nil,
            assigns: %{},
            correlation_id: nil,
            command: nil,
            events: nil,
            halted: false,
            handler: nil,
            owner: nil,
            params: %{},
            peer: nil,
            plugs: [],
            private: %{},
            retry: 0,
            status: :init

  @doc """
  Assigns a value to a key in the context.

  ## Examples

      iex> ctx.assigns[:hello]
      nil
      iex> ctx = assign(ctx, :hello, :world)
      iex> ctx.assigns[:hello]
      :world

  """
  def assign(%Context{assigns: assigns} = ctx, key, value) when is_atom(key) do
    %{ctx | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Assigns multiple values to keys in the context.

  Equivalent to multiple calls to `assign/3`.

  ## Examples

      iex> ctx.assigns[:hello]
      nil
      iex> ctx = merge_assigns(ctx, hello: :world)
      iex> ctx.assigns[:hello]
      :world

  """
  @spec merge_assigns(t, Keyword.t()) :: t
  def merge_assigns(%Context{assigns: assigns} = ctx, keyword) when is_list(keyword) do
    %{ctx | assigns: Enum.into(keyword, assigns)}
  end

  @doc """
  Assigns a new **private** key and value in the context.

  This storage is meant to be used by libraries and frameworks to avoid writing
  to the user storage (the `:assigns` field). It is recommended for
  libraries/frameworks to prefix the keys with the library name.

  For example, if some plug needs to store a `:hello` key, it
  should do so as `:plug_hello`:

      iex> ctx.private[:plug_hello]
      nil
      iex> ctx = put_private(ctx, :plug_hello, :world)
      iex> ctx.private[:plug_hello]
      :world

  """
  @spec put_private(t, atom, term) :: t
  def put_private(%Context{private: private} = ctx, key, value) when is_atom(key) do
    %{ctx | private: Map.put(private, key, value)}
  end

  @doc """
  Assigns multiple **private** keys and values in the context.

  Equivalent to multiple `put_private/3` calls.

  ## Examples

      iex> ctx.private[:plug_hello]
      nil
      iex> ctx = merge_private(ctx, plug_hello: :world)
      iex> ctx.private[:plug_hello]
      :world
  """
  @spec merge_private(t, Keyword.t()) :: t
  def merge_private(%Context{private: private} = ctx, keyword) when is_list(keyword) do
    %{ctx | private: Enum.into(keyword, private)}
  end

  @doc """
  Halts the Context pipeline by preventing further plugs downstream from being
  invoked. See the docs for `Helios.Aggregate.Context.Builder` for more information on halting a
  command context pipeline.
  """
  @spec halt(t) :: t
  def halt(%Context{} = ctx) do
    %{ctx | halted: true}
  end

  @spec emit_event(ctx :: Context.t(), nil | event) :: Context.t()
  def emit_event(%Context{} = ctx, nil), do: ctx

  def emit_event(%Context{events: events} = ctx, %{__struct__: event_type} = event) do
    events = List.wrap(events)

    domain_event = %Helios.Aggregate.DomainEvent{
      correlation_id: ctx.correlation_id,
      event_type: Atom.to_string(event_type),
      metadata: %{},
      data: event
    }

    %{ctx | events: events ++ [domain_event]}
  end
end

defimpl Inspect, for: Helios.Aggregate.Context do
  def inspect(ctx, opts) do
    ctx =
      if opts.limit == :infinity do
        ctx
      else
        update_in(ctx.events, fn {events, data} ->
          event_types =
            Enum.map(data, fn %{__struct__: event_module} ->
              "##{inspect(event_module)}<...>"
            end)

          {events, event_types}
        end)
      end

    Inspect.Any.inspect(ctx, opts)
  end
end

defimpl Collectable, for: Helios.Aggregate.Context do
  def into(data) do
    {data,
     fn data, _ ->
       data
     end}
  end
end
