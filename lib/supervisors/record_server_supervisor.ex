defmodule RecordServerSupervisor do
  use Supervisor
  alias Beiin.RecordServer
  alias Beiin.TimestampGenerator, as: TSG

  def start_link_load(metrics, tags, record_count, interval, start_time, opts \\ []) do
    children = [
      %{
        id: TSG,
        start: {TSG, :new, [start_time, interval, record_count, [name: TSG]]}
      },
      %{
        id: RecordServer,
        start: {RecordServer, :start_link, [metrics, tags, [name: RecordServer]]}
      }
    ]

    Supervisor.start_link(__MODULE__, children, opts)
  end

  def start_link_run(metrics, tags, record_count, interval, start_time, opts \\ []) do
    insert_start = start_time + interval * record_count

    children = [
      %{
        id: :read_tsg,
        start: {TSG, :new, [start_time, interval, record_count, [name: :read_tsg]]}
      },
      %{
        id: :ins_tsg,
        start: {TSG, :new, [insert_start, interval, record_count, [name: :ins_tsg]]}
      },
      %{
        id: RecordServer,
        start:
          {RecordServer, :start_link,
           [metrics, tags, [read_tsg: :read_tsg, ins_tsg: :ins_tsg, name: RecordServer]]}
      }
    ]

    Supervisor.start_link(__MODULE__, children, opts)
  end

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end
end
