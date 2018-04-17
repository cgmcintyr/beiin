defmodule Workload do
  defstruct name: 'Default workload',
            description: 'Default workload',
            record_count: 1_000,
            operation_count: 1_000,
            record_start: 0,
            interval: 1000,
            metrics: ["test_metric"],
            tags: [%{host: "test_host"}],
            load_worker_count: 10,
            read_worker_count: 10,
            insert_worker_count: 10,
            host: "localhost",
            port: 8080
end
