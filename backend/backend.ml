open! Core
open! Async
open! Cohttp
open! Cohttp_async

let api_pre = "/api/"
let api_pre_len = String.length api_pre

let static docroot req =
  match Request.meth req with
  | `GET ->
    let path = Path.resolve_local_file ~docroot ~uri:(Request.uri req) in
    let path =
      if Char.(path.[String.length path - 1] = '/') then path ^ "index.html" else path
    in
    Server.respond_with_file ~error_body:Respond_error.error_404 path
  | _ -> Respond_error.respond_405 ()
;;

let match_prefix s p =
  String.length s >= String.length p && String.(sub s ~pos:0 ~len:(length p) = p)
;;

let route body req =
  let path = Request.uri req |> Uri.path in
  let path = String.(sub ~pos:api_pre_len ~len:(length path - api_pre_len) path) in
  if match_prefix path "all"
  then (
    match Request.meth req with
    | `GET -> All.get path body req
    | _ -> Respond_error.respond_405 ())
  else if match_prefix path "image"
  then (
    match Request.meth req with
    | `GET -> Image.get path body req
    | _ ->  Respond_error.respond_405 ())
  else Respond_error.respond_404 ()
;;

let start_server port static_path username password uri () =
  Db.set_conn { username; password; uri = Uri.of_string uri };
  let%bind _ = Db.update_auth_token () in
  eprintf "Listening for HTTP on port %d\n" port;
  Server.create
    ~on_handler_error:`Raise
    (Tcp.Where_to_listen.of_port port)
    (fun ~body _ req ->
       let path = Request.uri req |> Uri.path in
       if match_prefix path api_pre then route body req else static static_path req)
  >>= fun _ -> Deferred.never () (* prevent garbage collection? *)
;;

let () =
  Command.async_spec
    ~summary:"Simple http server that outputs body of POST's"
    Command.Spec.(
      empty
      +> flag "-p" (optional_with_default 8000 int) ~doc:"Source port to listen on"
      +> flag
           "-s"
           (required string)
           ~doc:"Static file location that the server will serve"
      +> flag "-dbu" (required string) ~doc:"Username for the database"
      +> flag "-dbp" (required string) ~doc:"Password for the database"
      +> flag "-dburi" (required string) ~doc:"Uri for the database")
    start_server
  |> Command_unix.run
;;
