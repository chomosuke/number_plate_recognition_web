open Core
open Async
open Cohttp
open Cohttp_async

let static docroot req =
  let path = Path.resolve_local_file ~docroot ~uri:(Request.uri req) in
  let path =
    if Char.(path.[String.length path - 1] = '/') then path ^ "index.html" else path
  in
  Server.respond_with_file path
;;

let handle_request ~body req =
  match Request.meth req with
  | `GET ->
    let%bind _body = Body.to_string body in
    Server.respond_string "Hey there"
  | _ -> Server.respond `Method_not_allowed
;;

let start_server port static_path () =
  eprintf "Listening for HTTP on port %d\n" port;
  Server.create
    ~on_handler_error:`Raise
    (Tcp.Where_to_listen.of_port port)
    (fun ~body _ req ->
       let path = Request.uri req |> Uri.path in
       if String.length path >= 5 && String.(sub path ~pos:0 ~len:5 = "/api/")
       then handle_request ~body req
       else static static_path req)
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
