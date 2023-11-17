open Core
open Async
open Cohttp
open Cohttp_async

let api_pre = "/api/"
let api_pre_len = String.length api_pre
let error_404 = "<html><body><h1>404 Not Found</h1></body></html>"

let static docroot req =
  match Request.meth req with
  | `GET ->
    let path = Path.resolve_local_file ~docroot ~uri:(Request.uri req) in
    let path =
      if Char.(path.[String.length path - 1] = '/') then path ^ "index.html" else path
    in
    Server.respond_with_file ~error_body:error_404 path
  | _ -> Server.respond `Method_not_allowed
;;

let match_prefix s p =
  String.length s >= String.length p && String.(sub s ~pos:0 ~len:(length p) = p)
;;

let route body req =
  let path = Request.uri req |> Uri.path in
  let path = String.(sub ~pos:api_pre_len ~len:(length path - api_pre_len) path) in
  if match_prefix path "plates"
  then (
    match Request.meth req with
    | `GET -> Plates.get body req
    | _ -> Server.respond `Method_not_allowed)
  else Server.respond_string ~status:`Not_found error_404
;;

let start_server port static_path () =
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
      +> flag "-p" (optional_with_default 8080 int) ~doc:"int Source port to listen on"
      +> flag
           "-s"
           (required string)
           ~doc:"Static file location that the server will serve")
    start_server
  |> Command_unix.run
;;
