defmodule ExBase58.Impl do
  @moduledoc false

  use RustlerPrecompiled,
    otp_app: :ex_base58,
    crate: :ex_base58,
    base_url: "https://github.com/ayrat555/ex_base58/releases/download/v#{version}",
    force_build: System.get_env("EX_BASE58_BUILD") in ["1", "true"],
    version: version

  def encode(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def encode_check(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def encode_check_version(_data, _version, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def decode(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def decode_check(_data, _alphabet), do: :erlang.nif_error(:nif_not_loaded)

  def decode_check_version(_data, _version, _alphabet), do: :erlang.nif_error(:nif_not_loaded)
end
