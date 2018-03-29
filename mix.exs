defmodule Beiin.MixProject do
  use Mix.Project

  def project do
    [
      app: :beiin,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: [main_module: Commandline.CLI],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger, :yaml_elixir]
    ]
  end

  defp deps do
    [
      {:currying, "~> 1.0.0"},
      {:httpoison, "~> 1.0"},
      {:mox, "~> 0.3", only: :test},
      {:optimus, "~> 0.1.7"},
      {:poison, "~> 3.1"},
      {:yaml_elixir, "~> 1.3.1"}
    ]
  end
end
