open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic

let get_all_docs () = Db.query "/number_plates/_all_docs"

let get _body _req =
  let%bind all_docs = get_all_docs () in
  Server.respond_string (Json.to_string all_docs)
;;
