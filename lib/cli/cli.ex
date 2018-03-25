defmodule Commandline.CLI do
  require Logger

  defp log_yamerl_parsing_error(e) do
    type = elem(e, 1)
    text = elem(e, 2)
    fun = fn -> "Error loading worload config: #{text}" end
    case type do
      :error -> Logger.error(fun)
      _ -> Logger.warn(fun)
    end
    type
  end

  defp load_workload_cfg(path) do
    try do
      YamlElixir.read_from_file(path)
    catch
      {:yamerl_exception, errors} ->
        if Enum.map(errors, fn x -> log_yamerl_parsing_error(x) end) |> Enum.member?(:error) do
          Logger.flush()
          System.halt(1)
        end
      e -> IO.inspect(e)
    end
  end

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
            help: "Path to beiin workload configuration file",
            required: true,
            parser: :string
          ]
        ]
      )

    parsed = Optimus.parse!(optimus, args)
    path = parsed.args.config_file
    load_workload_cfg(path) |> IO.inspect
    Client.run("test")
  end
end
