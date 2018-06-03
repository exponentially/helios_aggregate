defmodule Helios.Aggregate.Pipeline.Plug do
  @type opts :: tuple | atom | integer | float | [opts]

  require Helios.Aggregate.Pipeline.Context

  @callback init(opts) :: opts
  @callback call(Helios.Aggregate.Context.t(), opts) ::
              Helios.Aggregate.Context.t()
end
