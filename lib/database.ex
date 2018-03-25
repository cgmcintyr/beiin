defmodule Database do
  @callback init(String.t, integer) :: {:ok, integer} | {:error, String.t}
  @callback insert(integer, integer) :: {:ok, integer} | {:error, String.t}
  @callback read(integer, integer) :: {:ok, integer} | {:error, String.t}
end
