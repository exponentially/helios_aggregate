defmodule Helios.Aggregate.Config do
  @moduledoc """
  Aggregate configuration helper functions
  """

  @doc """
  How often aggregate should save snapshot.

  Can be any positive integer and represents number
  of events/version between two snapshots. Default is `:never`. If you want
  to enable snapshots, in nutshell this number could be `1_000`.

  Please note, in most cases there is no need to use snapshots if your agregates are generating
  less than 1000 events.
  """
  @spec snapshot_every(aggregate_module :: atom()) :: integer | :never
  def snapshot_every(aggregate_module), do: get_config(aggregate_module, :snapshot_every, :never)

  @doc """
  Indivates version of snapshot schema. If you have to change snapshot schema, after
  deployments you can increase this number so handler which handles snapshot resotre
  could know from snapshot metadata what version of snapshot schema is. This way you can support
  any historical schema or ignore previous snapshot versions. More on this topic in `Helios.Aggregate.Snapshot`
  """
  @spec snapshot_version(aggregate_module :: atom()) :: integer
  def snapshot_version(aggregate_module), do: get_config(aggregate_module, :snapshot_version, 1)

  @doc """
  Reads configured command timout in milliseconds. Default value is 5000 milliseconds, same as GenServer message timout.
  """
  @spec command_timeout(aggregate_module :: atom()) :: integer
  def command_timeout(aggregate_module), do: get_config(aggregate_module, :default_command_timout, 5_000)

  @spec get_config(aggregate_module :: atom(), config_key :: atom(), any) :: any
  defp get_config(aggregate_module, config_key, default_value) do
    :helios_aggregate
    |> Application.get_env(aggregate_module, [])
    |> Keyword.get(config_key, default_value)
  end
end
