defmodule ExBase58.Impl do
  @moduledoc false

  use Rustler, otp_app: :ex_base58, crate: :exbase58

  def encode(_data), do: :erlang.nif_error(:nif_not_loaded)

  def decode(_data), do: :erlang.nif_error(:nif_not_loaded)
end
