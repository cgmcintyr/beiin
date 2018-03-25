defmodule Commandline.CLI do
  require Logger
  require Record

  defp log_yamerl_parsing_error(e) do
    {_, type, text, _, _, _, _, _} = e
    msg = "Error loading worload config: #{text}"

    case type do
      :error -> Logger.error(msg)
      _ -> Logger.warn(msg)
    end

    type
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
      YamlElixir.read_from_file(config_file) |> IO.inspect
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
