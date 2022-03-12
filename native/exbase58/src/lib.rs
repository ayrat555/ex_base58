use bs58::alphabet::Alphabet;
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
        invalid_alphabet
    }
}

#[rustler::nif]
fn encode<'a>(env: Env<'a>, binary: Binary, alphabet: String) -> Term<'a> {
    do_encode(env, binary, Some(alphabet), None)
}

#[rustler::nif]
fn encode_check<'a>(env: Env<'a>, binary: Binary, alphabet: String, version: u8) -> Term<'a> {
    do_encode(env, binary, Some(alphabet), Some(version))
}

#[rustler::nif]
fn decode<'a>(env: Env<'a>, binary: String, alphabet: String) -> Term<'a> {
    do_decode(env, binary, Some(alphabet), None)
}

#[rustler::nif]
fn decode_check<'a>(env: Env<'a>, binary: String, alphabet: String, version: u8) -> Term<'a> {
    do_decode(env, binary, Some(alphabet), Some(version))
}

fn do_decode<'a>(
    env: Env<'a>,
    binary: String,
    alphabet_option: Option<String>,
    version_option: Option<u8>,
) -> Term<'a> {
    let builder = bs58::decode(binary);

    let alphabet = match parse_alphabet(env, alphabet_option) {
        Ok(alph) => alph,
        Err(error) => return error,
    };

    let builder = match version_option {
        None => builder.with_alphabet(&alphabet),
        Some(_version) => builder.with_alphabet(&alphabet).with_check(version_option),
    };

    let result = builder.into_vec();

    match result {
        Ok(decoded) => encode_result(env, &decoded),
        Err(_) => (atoms::error(), atoms::decode_error()).encode(env),
    }
}

fn do_encode<'a>(
    env: Env<'a>,
    binary: Binary,
    alphabet_option: Option<String>,
    version_option: Option<u8>,
) -> Term<'a> {
    let builder = bs58::encode(binary.as_slice());

    let alphabet = match parse_alphabet(env, alphabet_option) {
        Ok(alph) => alph,
        Err(error) => return error,
    };

    let builder = match version_option {
        Some(version) => builder.with_alphabet(&alphabet).with_check_version(version),
        None => builder.with_alphabet(&alphabet),
    };

    let result = builder.into_string();

    encode_result(env, result.as_bytes())
}

fn parse_alphabet<'a>(env: Env<'a>, alphabet: Option<String>) -> Result<Alphabet, Term<'a>> {
    if let None = alphabet {
        return Ok(*Alphabet::BITCOIN);
    }

    match alphabet.unwrap().as_str() {
        "bitcoin" => Ok(*Alphabet::BITCOIN),
        "monero" => Ok(*Alphabet::MONERO),
        "flickr" => Ok(*Alphabet::FLICKR),
        "ripple" => Ok(*Alphabet::RIPPLE),
        _ => Err((atoms::error(), atoms::invalid_alphabet()).encode(env)),
    }
}

fn encode_result<'a>(env: Env<'a>, bytes: &[u8]) -> Term<'a> {
    let mut erl_bin = NewBinary::new(env, bytes.len());
    erl_bin.as_mut_slice().copy_from_slice(bytes);

    (atoms::ok(), Binary::from(erl_bin)).encode(env)
}

rustler::init!(
    "Elixir.ExBase58.Impl",
    [encode, encode_check, decode, decode_check]
);
