defmodule DatabaseWorkerTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  describe "DatbaseReadWorker Tests" do
    test "Run applies database module's read function" do
      response = %HTTPoison.Response{
        body: "{}",
        headers: [
          {"Server", "nginx"},
          {"Date", "Thu, 21 Jul 2016 16:52:38 GMT"},
          {"Content-Type", "application/json"},
          {"Content-Length", "397"},
          {"Connection", "keep-alive"},
          {"Keep-Alive", "timeout=10"},
          {"Vary", "Accept-Encoding"},
          {"Vary", "Accept-Encoding"},
          {"X-UA-Compatible", "IE=edge"},
          {"X-Frame-Options", "deny"},
          {"Content-Security-Policy", "default-src 'self'; script-src 'self' foo"},
          {"X-Content-Security-Policy", "default-src 'self'; script-src 'self' foo"},
          {"Cache-Control", "no-cache, no-store, must-revalidate"},
          {"Pragma", "no-cache"},
          {"X-Content-Type-Options", "nosniff"},
          {"Strict-Transport-Security", "max-age=31536000;"}
        ],
        status_code: 200
      }

      KairosDatabase.MockRequest |> expect(:timed_post, fn(_, _, _) -> {:ok, 1000, response} end)

      {:ok, pid} = DatabaseReadWorker.new(KairosDatabase)
      KairosDatabase.MockRequest |> allow(self(), pid)

      assert DatabaseReadWorker.exec(pid, 0) == {:ok, 1000}
    end
  end
end
