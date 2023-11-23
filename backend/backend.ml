open! Core
open! Async
open! Cohttp
open! Cohttp_async

let api_root = "/api/"
let api_root_len = String.length api_root

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
  (* let%bind () = Async_kernel.after (Time_ns.Span.of_sec 1.) in *)
  let path = Request.uri req |> Uri.path in
  let path = String.(sub ~pos:api_root_len ~len:(length path - api_root_len) path) in
  if match_prefix path "plates"
  then (
    match Request.meth req with
    | `GET -> Plates.get body req
    | _ -> Respond_error.respond_405 ())
  else if match_prefix path "image"
  then (
    match Request.meth req with
    | `GET -> Image.get body req
    | _ -> Respond_error.respond_405 ())
  else if match_prefix path "login"
  then (
    match Request.meth req with
    | `POST -> Login.post body req
    | _ -> Respond_error.respond_405 ())
  else Respond_error.respond_404 ()
;;

let start_server port static_path secret username password uri () =
  Db.set_conn { username; password; uri = Uri.of_string uri };
  Aes.set_secret secret;
  let%bind _ = Db.update_auth_token () in
  eprintf "Listening for HTTP on port %d\n" port;
  Server.create
    ~on_handler_error:`Raise
    (Tcp.Where_to_listen.of_port port)
    (fun ~body _ req ->
       let path = Request.uri req |> Uri.path in
       if match_prefix path api_root then route body req else static static_path req)
  >>= fun _ -> Deferred.never () (* prevent garbage collection? *)
;;

let () =
  Command.async_spec
    ~summary:"Simple http server that outputs body of POST's"
    Command.Spec.(
      empty
      +> flag "-port" (optional_with_default 8000 int) ~doc:"Source port to listen on"
      +> flag
           "-path"
           (required string)
           ~doc:"Static file location that the server will serve"
      +> flag
           "-secret"
           (required string)
           ~doc:"Secret that the server use to handout cookies"
      +> flag "-dbu" (required string) ~doc:"Username for the database"
      +> flag "-dbp" (required string) ~doc:"Password for the database"
      +> flag "-dburi" (required string) ~doc:"Uri for the database")
    start_server
  |> Command_unix.run
;;
