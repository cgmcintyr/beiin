defmodule DatabaseWorkerTest do
  use ExUnit.Case, async: true

  describe "DatbaseReadWorker Tests" do
    test "Run applies function passed to DatabaseReadWorker.new" do
      {:ok, pid} = DatabaseReadWorker.new(fn -> "test output" end)
      assert DatabaseReadWorker.run(pid) == "test output"
    end

    test "Multiple DatabaseReadWorker can exist at once" do
      {:ok, pid1} = DatabaseReadWorker.new(fn -> "test output1" end)
      {:ok, pid2} = DatabaseReadWorker.new(fn -> "test output2" end)
      assert DatabaseReadWorker.run(pid1) == "test output1"
      assert DatabaseReadWorker.run(pid2) == "test output2"
    end
  end

  describe "DatbaseInsertWorker Tests" do
    test "Run applies function passed to DatabaseInsertWorker.new" do
      {:ok, pid} = DatabaseInsertWorker.new(fn -> "test output" end)
      assert DatabaseInsertWorker.run(pid) == "test output"
    end

    test "Multiple DatabaseInsertWorker can exist at once" do
      {:ok, pid1} = DatabaseInsertWorker.new(fn -> "test output1" end)
      {:ok, pid2} = DatabaseInsertWorker.new(fn -> "test output2" end)
      assert DatabaseInsertWorker.run(pid1) == "test output1"
      assert DatabaseInsertWorker.run(pid2) == "test output2"
    end
  end
end
