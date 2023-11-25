open! Core
open Nocrypto
module AES = Cipher_block.AES.CBC
open Cstruct

let () = Nocrypto_entropy_unix.initialize ()
let secret = ref None
let set_secret s = secret := Some (s |> of_string |> Hash.SHA256.digest |> AES.of_secret)

let pad ~padding str =
  let rem = String.length str mod AES.block_size in
  if rem = 0 then str else str ^ String.make (AES.block_size - rem) padding
;;

let iv_size = AES.block_size

let encrypt ?(padding = ' ') str =
  let key = Option.value_exn !secret in
  let iv = Rng.generate iv_size in
  AES.encrypt ~key ~iv (str |> pad ~padding |> of_string)
  |> append iv
  |> Base64.encode
  |> to_string
;;

let decrypt str =
  let key = Option.value_exn !secret in
  let open Option.Let_syntax in
  let%bind c = str |> of_string |> Base64.decode in
  try
    Some
      (let iv, c = split c iv_size in
       c |> AES.decrypt ~key ~iv |> to_string)
  with
  | Invalid_argument _ -> None
;;
