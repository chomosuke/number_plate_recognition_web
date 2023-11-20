open! Core
open! Async
open! Cohttp
open! Cohttp_async

let get path _body _req =
  match String.split_on_chars ~on:[ '/' ] path with
  | _ :: id :: filename :: _ ->
    let path = Db.plates_root ^ id ^ "/" ^ filename in
    let%bind body = Db.query_raw path >>| Body.to_pipe in
    Server.respond_with_pipe body
  | _ -> Respond_error.respond_404 ()
;;
