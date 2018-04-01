defmodule RunRecordServerSupervisor do
  use Supervisor

  def start_link(metrics, tags, record_count, interval, start_time, opts \\ []) do
    insert_start = start_time + interval * record_count

    children = [
      %{
        id: TimestampGenerator,
        start: {TimestampGenerator, :new, [start_time, interval, record_count, [name: :read_tsg]]}
      },
      %{
        id: RecordServer,
        start:
          {RecordServer, :start_link, [metrics, tags, :read_tsg, [name: :read_record_server]]}
      },
      %{
        id: TimestampGenerator,
        start:
          {TimestampGenerator, :new, [insert_start, interval, record_count, [name: :insert_tsg]]}
      },
      %{
        id: RecordServer,
        start:
          {RecordServer, :start_link, [metrics, tags, :insert_tsg, [name: :insert_record_server]]}
      }
    ]

    Supervisor.start_link(__MODULE__, children, opts)
  end

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end
end
