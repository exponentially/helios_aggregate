defmodule Helios.Aggregate.Lifespan do
  @moduledoc """
  When module implments `Helios.Aggregates.Lifespan` it should define how
  long aggregate will stay running as process.

  ## Supported return values

    - Non negative integer - miliseconds
    - `:infinity` - will never shutting down aggregate process.
    - `:hibernate` - send the aggregate process into hibernation.
    - `:stop` - shutdown the aggregate process right away.
  """
  @callback call(context :: struct(), aggregate :: struct()) :: struct()
end
