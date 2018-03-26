defmodule Database do
  @callback init(String.t(), integer) :: {:ok, integer} | {:error, String.t()}
  @callback insert(String.t(), integer, integer) :: {:ok, integer} | {:error, String.t()}
  @callback read(String.t(), integer, integer) :: {:ok, integer} | {:error, String.t()}
end
