open! Core
open Nocrypto
module AES = Cipher_block.AES.CBC
open Cstruct

let secret : string option ref = ref None
let set_secret s = secret := Some s
let () = Nocrypto_entropy_unix.initialize ()

let pad ~padding str =
  let rem = String.length str mod AES.block_size in
  if rem = 0 then str else str ^ String.make (AES.block_size - rem) padding
;;

let encrypt ?(padding = ' ') str =
  let secret = Option.value_exn !secret in
  AES.encrypt
    ~key:(secret |> of_string |> Hash.SHA256.digest |> AES.of_secret)
    ~iv:(Rng.generate AES.block_size)
    (str |> pad ~padding |> of_string)
  |> Base64.encode
  |> to_string
;;

let decrypt str =
  let secret = Option.value_exn !secret in
  try
    Option.Monad_infix.(
      str
      |> of_string
      |> Base64.decode
      >>| AES.decrypt
            ~key:(secret |> of_string |> Hash.SHA256.digest |> AES.of_secret)
            ~iv:(Rng.generate AES.block_size)
      >>| to_string)
  with
  | exn -> raise exn
;;
