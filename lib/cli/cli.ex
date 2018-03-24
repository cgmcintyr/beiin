defmodule Commandline.CLI do
  def main(args) do
    optimus =
      Optimus.new!(
        name: "beiin",
        description: "Beiin TSDB Benchmarking Tool",
        version: "0.0.1",
        author: "Christopher G Mcintyre me@cgmcintyre.com",
        about: "Utility for benchmarking different time series databases with custom workloads.",
        allow_unknown_args: false,
        parse_double_dash: true,
        args: [
          config_file: [
            value_name: "CONFIG_FILE",
            help: "Path to beiin configuration file",
            required: true,
            parser: :string
          ]
        ]
      )

    parsed = Optimus.parse!(optimus, args)
    config_file = parsed.args.config_file
  end
end
