defmodule Helios.AggregateTest do
  use ExUnit.Case
  doctest Helios.Aggregate


  import ExUnit.CaptureLog

  alias Helios.Aggregate
  alias Helios.Aggregate.Pipeline.Context

  # Events
  defmodule CustomerCreated do
    defstruct [:id, :first_name, :last_name]
  end

  defmodule CustomerContactCreated do
    defstruct [:email]
  end

  defmodule CustomerAggregate do
    use Helios.Aggregate
    require Logger

    # Aggregate State
    defstruct [:first_name, :last_name, :email, :password]

    # Plugs for command context pipeline
    plug(:log, :logger_plug_options)

    def create_user(ctx, %{first_name: first_name, last_name: last_name, email: email}) do
      customer_created = %CustomerCreated{first_name: first_name, last_name: last_name}
      customer_contact_created = %CustomerContactCreated{email: email}

      ctx
      |> emit_event(customer_created)
      |> emit_event(customer_contact_created)
      |> assign(:customer_id, 1_234_567)
    end

    def apply_event(_, agg), do: agg

    def log(ctx, opts) do
      Logger.info("Executing #{ctx.aggregate_module}.#{ctx.command}")
      %{ctx | private: Map.put(ctx.private, :aggregate_logger, opts)}
    end
  end

  test "should execute logger in aggregate pipeline" do
    assert [] == CustomerAggregate.init([])

    ctx_before = %Context{
      aggregate: %Aggregate{
        state: struct(CustomerAggregate)
      },
      aggregate_module: CustomerAggregate,
      correlation_id: "1234567890",
      command: :create_user,
      peer: self(),
      params: %{first_name: "Jhon", last_name: "Doe", email: "jhon.doe@gmail.com"}
    }

    ctx_after = %{
      ctx_before
      | assigns: %{customer_id: 1_234_567},
        events: [
          %Helios.Aggregate.DomainEvent{
            correlation_id: "1234567890",
            event_type: "Elixir.Helios.AggregateTest.CustomerCreated",
            data: %CustomerCreated{
              first_name: "Jhon",
              id: nil,
              last_name: "Doe"
            },
            metadata: %{}
          },
          %Helios.Aggregate.DomainEvent{
            correlation_id: "1234567890",
            event_type: "Elixir.Helios.AggregateTest.CustomerContactCreated",
            data: %CustomerContactCreated{
              email: "jhon.doe@gmail.com"
            },
            metadata: %{
            }
          }
        ],
        private: %{
          aggregate_logger: :logger_plug_options,
          helios_aggregate: CustomerAggregate,
          helios_aggregate_command_handler: :create_user
        }
    }

    assert capture_log(fn ->
             assert ctx_after == CustomerAggregate.call(ctx_before, :create_user)
           end) =~ "Executing #{CustomerAggregate}.create_user"
  end

end
