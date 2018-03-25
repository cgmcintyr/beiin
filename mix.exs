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
      extra_applications: [:logger, :yaml_elixir]
    ]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 1.3.1"},
      {:optimus, "~> 0.1.7"}
    ]
  end
end
