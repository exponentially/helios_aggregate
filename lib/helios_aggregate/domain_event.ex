defmodule Helios.Aggregate.DomainEvent do
  @moduledoc """
  DomainEvent contains the data for a single event just emitted by aggregate and
  before being persisted to event stream.
  """
  defstruct [:causation_id, :correlation_id, :data, :event_type, :metadata]

  @type metadata_value :: String.t() | integer | float
  @type metadata :: %{atom => metadata_value}

  @type t :: %__MODULE__{
          causation_id: String.t(),
          correlation_id: String.t(),
          data: binary,
          event_type: String.t() | atom,
          metadata: binary
        }
end
