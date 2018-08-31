defmodule Helios.Aggregate.MixProject do
  use Mix.Project

  @version "0.1.1"
  @maintainers [
    "Milan Jarić"
  ]

  def project do
    [
      app: :helios_aggregate,
      version: @version,
      elixir: "~> 1.4 or ~> 1.5 or ~> 1.6 or ~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/exponentially/helios_aggregate",
      # Hex
      description: description(),
      package: package(),
      # Docs
      name: "Helios Aggregate",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Elixir library defining Aggregate behaviour and providing extendable facility for aggregate command pipeline."
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp docs() do
    [
      main: "Helios.Aggregate",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/helios_aggregate",
      # logo: "guides/images/logo.png",
      source_url: "https://github.com/exponentially/helios_aggregate",
      extras: [
        "README.md"
      ],
      groups_for_modules: [
        "Aggregate": [
          Helios.Aggregate,
          Helios.Aggregate.DomainEvent,
          Helios.Aggregate.Config,
          Helios.Aggregate.CommandHandlerClauseError
        ],
        "Command Pipeline": [
          Helios.Aggregate.Pipeline.Builder,
          Helios.Aggregate.Pipeline.Context,
          Helios.Aggregate.Pipeline.Plug,
          Helios.Aggregate.Logger
        ]
      ]
    ]
  end

  defp package() do
    [
      maintainers: @maintainers,
      licenses: ["Apache 2.0"],
      links: %{github: "https://github.com/exponentially/helios_aggregate"},
      files: ~w(lib) ++ ~w(CHANGELOG.md LICENSE mix.exs README.md)
    ]
  end
end
