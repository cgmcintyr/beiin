defmodule Database do
  @callback init(
              host :: String.t(),
              port :: integer
            ) :: {:ok, integer} | {:error, String.t()}

  @callback insert(
              host :: String.t(),
              port :: integer,
              metric :: String.t(),
              timestamp :: integer,
              value :: integer,
              tags :: map()
            ) :: {:ok, integer} | {:error, String.t()}

  @callback read(
              host :: String.t(),
              port :: integer,
              metric :: String.t(),
              timestamp :: integer
            ) :: {:ok, integer} | {:error, String.t()}
end
