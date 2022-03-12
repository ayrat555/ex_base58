defmodule ExBase58.Impl do
  @moduledoc false

  use Rustler, otp_app: :ex_base58, crate: :exbase58

  def encode(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def encode_check(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def encode_check_version(_data, _alphabet, _version), do: :erlang.nif_error(:nif_not_loaded)

  def decode(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def decode_check(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def decode_check_version(_data, _alphabet, _version), do: :erlang.nif_error(:nif_not_loaded)
end
