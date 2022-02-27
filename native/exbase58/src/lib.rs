use base58::FromBase58;
use base58::ToBase58;
use rustler::types::binary::Binary;
use rustler::types::binary::NewBinary;
use rustler::Encoder;
use rustler::Env;
use rustler::Term;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        decode_error,
    }
}

#[rustler::nif]
fn encode<'a>(env: Env<'a>, binary: Binary) -> Binary<'a> {
    let encoded = &binary.as_slice().to_base58();

    let mut erl_bin = NewBinary::new(env, encoded.len());
    erl_bin.as_mut_slice().copy_from_slice(&encoded.as_bytes());

    erl_bin.into()
}

#[rustler::nif]
fn decode<'a>(env: Env<'a>, binary: String) -> Term<'a> {
    match binary.from_base58() {
        Ok(decoded) => {
            let mut erl_bin = NewBinary::new(env, decoded.len());
            erl_bin.as_mut_slice().copy_from_slice(&decoded);

            (atoms::ok(), Binary::from(erl_bin)).encode(env)
        }

        Err(_) => (atoms::error(), atoms::decode_error()).encode(env),
    }
}

rustler::init!("Elixir.ExBase58.Impl", [encode, decode]);
