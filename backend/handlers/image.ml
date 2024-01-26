open! Core
open! Async
open! Cohttp
open! Cohttp_async

let get _body req =
  let path = Request.uri req |> Uri.path in
  match String.split_on_chars ~on:[ '/' ] path with
  | [ _; _; _; id; filename ] ->
    if String.length filename = 0
    then Respond_error.respond_404 ()
    else (
      let%bind pipe = Db.get_attachment Db.plates id filename in
      match pipe with
      | Some pipe -> Server.respond_with_pipe pipe
      | None -> Respond_error.respond_404 ())
  | _ -> Respond_error.respond_404 ()
;;
