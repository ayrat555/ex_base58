defmodule ExBase58 do
  @moduledoc """
  Base58 encoding and decoding.

  Every function in this module accepts additonal optional parameter - alphabet. Default alphabet is `:bitcoin`.

  It uses https://github.com/mycorrhiza/bs58-rs rust library
  """

  alias ExBase58.Impl

  @type alphabet :: :bitcoin | :monero | :ripple | :flickr

  @doc """
  Encodes binary into Base58 format.

  ## Examples

      iex> ExBase58.encode("hello")
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
  @spec encode(binary(), alphabet()) :: {:ok, String.t()} | {:error, atom()}
  def encode(binary, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.encode(binary, alphabet)
    end
  end

  @doc """
  Encodes binary into Base58Check format

  ## Examples

      iex> ExBase58.encode_check(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 0)
      {:ok, "1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN"}

      iex> ExBase58.encode_check(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 111)
      {:ok, "mw5TEFcvnLvgAZyLdAGbKEi2MvDHF1HXJX"}

      iex> ExBase58.encode_check(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 111, :ripple)
      {:ok, "mAnTNEcv8LvgwZyLdwGbKN5pMvDHErHXJX"}
  """
  @spec encode_check(binary(), non_neg_integer(), alphabet()) ::
          {:ok, binary()} | {:error, atom()}
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
  @spec decode(String.t(), alphabet()) :: {:ok, binary()} | {:error, atom()}
  def decode(encoded, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.decode(encoded, alphabet)
    end
  end

  @doc """
  Decodes from Base58Check format

  ## Examples

      iex> ExBase58.decode_check("1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN", 0)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}

      iex> ExBase58.decode_check("mw5TEFcvnLvgAZyLdAGbKEi2MvDHF1HXJX", 111)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}

      iex> ExBase58.decode_check("mAnTNEcv8LvgwZyLdwGbKN5pMvDHErHXJX", 111, :ripple)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}
  """
  @spec decode_check(binary(), non_neg_integer(), alphabet()) ::
          {:ok, binary()} | {:error, atom()}
  def decode_check(binary, version, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet),
         {:ok, <<^version>> <> decoded} <- Impl.decode_check(binary, alphabet, version) do
      {:ok, decoded}
    end
  end

  defp alphabet_to_string(alphabet) when alphabet in [:bitcoin, :monero, :flickr, :ripple] do
    {:ok, Atom.to_string(alphabet)}
  end

  defp alphabet_to_string(_alphabet) do
    {:error, :invalid_alphabet}
  end
end
