defmodule ExBase58 do
  @moduledoc """
  Base58 encoding and decoding.

  It uses https://github.com/debris/base58 rust library
  """

  alias ExBase58.Impl

  @doc """
  Encodes into Base58 format

  ## Examples

      iex> ExBase58.encode("hey")
      "c4oi"

      iex> ExBase58.encode("hello")
      "Cn8eVZg"
  """
  @spec encode(binary()) :: String.t()
  def encode(binary), do: Impl.encode(binary)

  @doc """
  Decodes from Base58 format

  ## Examples

      iex> ExBase58.decode("c4oi")
      {:ok, "hey"}

      iex> ExBase58.decode("Cn8eVZg")
      {:ok, "hello"}

      iex> ExBase58.decode("Hello")
      {:error, :decode_error}
  """
  @spec decode(String.t()) :: {:ok, binary()} | {:error, :decode_error}
  def decode(encoded), do: Impl.decode(encoded)
end
