# Helios.Aggregate

Elixir library defining Aggregate behaviour and providing extendable facility for aggregate command pipeline.

*NOTE: Library is stil under developement and not production ready.*

Please note this package is not full CQRS framework. We strongly disagree that CQRS can be boxed into framewrok, it is rather set of
techniques you CAN apply to your service architecture.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `helios_aggregate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:helios_aggregate, "~> 0.1"}
  ]
end
```

## Aggregate example

```elixir
defmodule Customer do
  use Helios.Aggregate

  # Aggregate state
  defstruct [:first_name, :last_name, :email]

  # Events emitted by aggregate
  defmodule CustomerCreated, do: defstruct [:id, :first_name, :last_name]
  defmodule CustomerContactCreated, do: defstruct [:email]

  def create(ctx, %{first_name: first_name, last_name: last_name, email: email}) do
    
    ctx
    |> emit_event(%CustomerCreated{first_name: first_name, last_name: last_name})
    |> emit_event(%CustomerContactCreated{email: email})
  end

  def apply_event(customer, %CustomerCreated{}=event) do
    %{customer|
      first_name: event.first_name,
      last_name: event.last_name
    }
  end

  def apply_event(customer, %CustomerContactCreated{email: email}) do
    %{customer| email: email}
  end
end
```

```elixir
  ctx = %Helios.Aggregate.Pipeline.Context{
    aggregate: %Helix.Aggregate{state: },
    aggregate_module: CustomerAggregate,
    correlation_id: "1234567890",
    command: :create_user,
    peer: self(),
    params: %{first_name: "Jhon", last_name: "Doe", email: "jhon.doe@gmail.com"}
  }

  Cusomer.call(ctx, :create)
    
```

## Logger configuration

We build logger which should log each command sent to aggregate. Since commands can cary some confidential information, or you have to be PCI DSS compliant, 
we expsed configuration like below where you could configure which filed values in command should be retracted.

Below is example where list of field names are given. Please note, the logger plug will not try to conver string to atom or other way round, if you have both case
please state them in list as both, string and atom.
```elixir
use Mix.Config

# filter only specified
config :helios_aggregate, 
  :filter_parameters, [:password, "password", :credit_card_number]

# filter all but keep original values
config :helios_aggregate, 
  :filter_parameters, {:keep, [:email, "email", :full_name]}

# retract only specified field values
config :helios_aggregate, 
  :filter_parameters, [:password, "password", :credit_card_number]


```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/helios_aggregate](https://hexdocs.pm/helios_aggregate).

