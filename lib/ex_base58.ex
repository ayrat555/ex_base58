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
  Same as encode/2, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.encode!("hello")
      "Cn8eVZg"

      iex> ExBase58.encode!("hello", :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec encode!(binary(), alphabet()) :: String.t()
  def encode!(binary, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, value} = Impl.encode(binary, str_alphabet)
    value
  end

  @doc """
  Encodes binary including checksum calculated using the Base58Check algorithm and version

  ## Examples

      iex> ExBase58.encode_check_version(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 0)
      {:ok, "1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN"}

      iex> ExBase58.encode_check_version(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 111)
      {:ok, "mw5TEFcvnLvgAZyLdAGbKEi2MvDHF1HXJX"}

      iex> ExBase58.encode_check_version(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 111, :ripple)
      {:ok, "mAnTNEcv8LvgwZyLdwGbKN5pMvDHErHXJX"}
  """
  @spec encode_check_version(binary(), non_neg_integer(), alphabet()) ::
          {:ok, binary()} | {:error, atom()}
  def encode_check_version(binary, version, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.encode_check_version(binary, alphabet, version)
    end
  end

  @doc """
  Same as encode_check_version/3, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.encode_check_version!(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 0)
      "1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN"

      iex> ExBase58.encode_check_version!(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, 0, :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec encode_check_version!(binary(), non_neg_integer(), alphabet()) :: binary()
  def encode_check_version!(binary, version, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, value} = Impl.encode_check_version(binary, str_alphabet, version)
    value
  end

  @doc """
  Encodes binary including checksum calculated using the Base58Check algorithm

  ## Examples

      iex> ExBase58.encode_check(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, :monero)
      {:ok, "GZVwCXwyKVRPTViubJDVKVhVvcaKpEnqR"}

      iex> ExBase58.encode_check(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, :ripple)
      {:ok, "GZVAUXAyKVRPTV5ubJDVKV6Vvc2KFN8qR"}
  """
  @spec encode_check(binary(), alphabet()) :: {:ok, String.t()} | {:error, atom()}
  def encode_check(binary, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.encode_check(binary, alphabet)
    end
  end

  @doc """
  Same as encode_check/2, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.encode_check!(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, :monero)
      "GZVwCXwyKVRPTViubJDVKVhVvcaKpEnqR"

      iex> ExBase58.encode_check!(<<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>, :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec encode_check!(binary(), alphabet()) :: String.t()
  def encode_check!(binary, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, value} = Impl.encode_check(binary, str_alphabet)
    value
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
  Same as decode/2, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.decode!("2gsG")
      <<5, 6, 7>>

      iex> ExBase58.decode!("cM8DuyF", :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec decode!(String.t(), alphabet()) :: binary()
  def decode!(encoded, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, value} = Impl.decode(encoded, str_alphabet)
    value
  end

  @doc """
  Decodes binary checking checksum using the Base58Check algorithm. The version byte will be used in verification.

  ## Examples

      iex> ExBase58.decode_check_version("1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN", 0)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}

      iex> ExBase58.decode_check_version("mw5TEFcvnLvgAZyLdAGbKEi2MvDHF1HXJX", 111)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}

      iex> ExBase58.decode_check_version("mAnTNEcv8LvgwZyLdwGbKN5pMvDHErHXJX", 111, :ripple)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}
  """
  @spec decode_check_version(binary(), non_neg_integer(), alphabet()) ::
          {:ok, binary()} | {:error, atom()}
  def decode_check_version(binary, version, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet),
         {:ok, <<^version>> <> decoded} <-
           Impl.decode_check_version(binary, alphabet, version) do
      {:ok, decoded}
    end
  end

  @doc """
  Same as decode_check_version/3, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.decode_check_version!("1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN", 0)
      <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>

      iex> ExBase58.decode_check_version!("1GZVwCXwyKVRPTViubJDVKVhVvcaEoX5cN", 0, :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec decode_check_version!(binary(), non_neg_integer(), alphabet()) :: binary()
  def decode_check_version!(binary, version, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, <<^version>> <> decoded} = Impl.decode_check_version(binary, str_alphabet, version)
    decoded
  end

  @doc """
  Decodes binary checking checksum using the Base58Check algorithm.

  ## Examples

      iex> ExBase58.decode_check("GZVwCXwyKVRPTViubJDVKVhVvcaKpEnqR", :monero)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}

      iex> ExBase58.decode_check("GZVAUXAyKVRPTV5ubJDVKV6Vvc2KFN8qR", :ripple)
      {:ok, <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>}
  """
  @spec decode_check(binary(), alphabet()) :: {:ok, String.t()} | {:error, atom()}
  def decode_check(binary, alphabet \\ :bitcoin) do
    with {:ok, alphabet} <- alphabet_to_string(alphabet) do
      Impl.decode_check(binary, alphabet)
    end
  end

  @doc """
  Same as decode_check/2, but returns a string value instead of a tuple and raises if the alphabet is wrong

  ## Examples

      iex> ExBase58.decode_check!("GZVwCXwyKVRPTViubJDVKVhVvcaKpEnqR", :monero)
      <<170, 175, 89, 206, 129, 197, 74, 82, 170, 144, 47, 81, 120, 199, 251, 203, 167, 32, 54, 7>>

      iex> ExBase58.decode_check!("GZVwCXwyKVRPTViubJDVKVhVvcaKpEnqR", :not_listed)
      ** (ArgumentError) Invalid alphabet
  """
  @spec decode_check!(binary(), alphabet()) :: String.t()
  def decode_check!(binary, alphabet \\ :bitcoin) do
    str_alphabet = alphabet_to_string!(alphabet)
    {:ok, value} = Impl.decode_check(binary, str_alphabet)
    value
  end

  defp alphabet_to_string(alphabet) when alphabet in [:bitcoin, :monero, :flickr, :ripple] do
    {:ok, Atom.to_string(alphabet)}
  end

  defp alphabet_to_string(_alphabet) do
    {:error, :invalid_alphabet}
  end

  defp alphabet_to_string!(alphabet) do
    case alphabet_to_string(alphabet) do
      {:ok, value} ->
        value

      {:error, _} ->
        raise ArgumentError, "Invalid alphabet"
    end
  end
end
