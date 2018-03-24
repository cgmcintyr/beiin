defmodule Commandline.CLI do
  require Logger

  def parse_config_file(document) do
    List.foldl(document, %{}, fn({k, v}, acc) -> Map.put(acc, k, v) end)
  end

  def log_yamerl_parsing_error(e) do
    {yamerl_error, type, text, line, column, name, token, extra} = e
    case type do
      :error ->
        Logger.error fn -> "#{text}" end
        :error
      :warning ->
        Logger.warn fn -> "#{text}" end
        :warning
      _ ->
        Logger.error fn -> "#{text}" end
        :error
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
            help: "Path to beiin configuration file",
            required: true,
            parser: :string
          ]
        ]
      )

    parsed = Optimus.parse!(optimus, args)
    config_file = parsed.args.config_file
    try do
      [ document | _ ] = :yamerl_constr.file(config_file)
      parse_config_file(document) |> IO.inspect
    catch
      {:yamerl_exception, errors} ->
        Enum.map(errors, fn x -> log_yamerl_parsing_error(x) end)
        exit(:parse_workload_config_error)
      e ->
        IO.inspect(e)
    end
  end
end
