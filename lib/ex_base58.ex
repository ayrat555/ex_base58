defmodule ExBase58 do
  @moduledoc """
  Base58 encoding and decoding.

  It uses https://github.com/debris/base58 rust library
  """

  alias ExBase58.Impl

  @doc """
  Encodes into Base58 format

  ## Examples

      iex> ExBase58.encode("hello", :bitcoin)
      {:ok, "Cn8eVZg"}

      iex> ExBase58.encode("hello", :monero)
      {:ok, "Cn8eVZg"}

      iex> ExBase58.encode("hello", :ripple)
      {:ok, "U83eVZg"}

      iex> ExBase58.encode("hello", :flickr)
      {:ok, "cM8DuyF"}

      iex> ExBase58.encode("hello", :meow)
      {:error, :invalid_alphabet}

      iex> ExBase58.encode(<<5, 6, 7>>)
      {:ok, "2gsG"}
  """
  @spec encode(binary(), atom()) :: {:ok, String.t()} | {:error, atom()}
  def encode(binary, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.encode(binary, alphabet)
    end
  end

  @spec encode_check(binary(), non_neg_integer(), atom()) :: {:ok, binary()} | {:error, atom()}
  def encode_check(binary, version, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.encode_check(binary, alphabet, version)
    end
  end

  @doc """
  Decodes from Base58 format

  ## Examples

      iex> ExBase58.decode("c4oi")
      {:ok, "hey"}

      iex> ExBase58.decode("Cn8eVZg")
      {:ok, "hello"}

      iex> ExBase58.decode("U83eVZg", :ripple)
      {:ok, "hello"}

      iex> ExBase58.decode("cM8DuyF", :flickr)
      {:ok, "hello"}

      iex> ExBase58.decode("Hello")
      {:error, :decode_error}

      iex> ExBase58.decode("cM8DuyF", :meow)
      {:error, :invalid_alphabet}

      iex> ExBase58.decode("2gsG")
      {:ok, <<5, 6, 7>>}
  """
  @spec decode(String.t(), atom()) :: {:ok, binary()} | {:error, atom()}
  def decode(encoded, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.decode(encoded, alphabet)
    end
  end

  @spec decode_check(binary(), non_neg_integer(), atom()) :: {:ok, binary()} | {:error, atom()}
  def decode_check(binary, version, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.decode_check(binary, alphabet, version)
    end
  end

  defp alphabet_to_string(alphabet) when alphabet in [:bitcoin, :monero, :flickr, :ripple] do
    {:ok, Atom.to_string(alphabet)}
  end

  defp alphabet_to_string(_alphabet) do
    {:error, :invalid_alphabet}
  end
end
