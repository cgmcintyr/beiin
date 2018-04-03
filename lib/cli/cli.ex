defmodule Beiin.CLI do
  require Logger

  alias Beiin.Client

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
        subcommands: [
          run: [
            name: "run",
            about: "Run timeseries workload",
            args: [
              workload_file: [
                value_name: "WORKLOAD",
                help: "Path to beiin workload configuration file",
                required: true,
                parser: :string
              ]
            ]
          ],
          load: [
            name: "load",
            about: "Load data required to run workload",
            args: [
              workload_file: [
                value_name: "WORKLOAD",
                help: "Path to beiin workload configuration file",
                required: true,
                parser: :string
              ]
            ]
          ]
        ]
      )

    {command_path, parsed} = Optimus.parse!(optimus, args)

    path = parsed.args.workload_file
    cfg = load_workload(path) |> to_struct(Workload)

    case command_path do
      [:load] -> Client.load(cfg)
      [:run] -> Client.run(cfg)
      _ -> optimus |> Optimus.help() |> IO.puts()
    end
  end

  defp to_struct(map, kind) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(map, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

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

  defp load_workload(path) do
    try do
      YamlElixir.read_from_file(path)
    catch
      {:yamerl_exception, errors} ->
        if Enum.map(errors, fn x -> log_yamerl_parsing_error(x) end) |> Enum.member?(:error) do
          Logger.flush()
          System.halt(1)
        end

      e ->
        IO.inspect(e)
    end
  end
end
