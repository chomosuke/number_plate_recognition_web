open! Core
open! Async
open! Cohttp
open! Cohttp_async

let get path _body _req =
  match String.split_on_chars ~on:[ '/' ] path with
  | [ _; id; filename ] ->
    if String.length filename = 0
    then Respond_error.respond_404 ()
    else (
      let path = Db.plates_root ^ id ^ "/" ^ filename in
      let%bind res, body = Db.query_raw path in
      match Response.status res with
      | `OK -> Server.respond_with_pipe @@ Body.to_pipe body
      | `Not_found -> Respond_error.respond_404 ()
      | _ -> raise (Db.UnexpectedResponse (res, body)))
  | _ -> Respond_error.respond_404 ()
;;
