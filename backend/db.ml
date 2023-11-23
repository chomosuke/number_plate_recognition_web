open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic

let auth_token = ref None

type conn =
  { username : string
  ; password : string
  ; uri : Uri.t
  }

let conn : conn option ref = ref None
let set_conn value = conn := Some value

exception UnexpectedResponse of Response.t * Body.t [@@deriving sexp]
exception WrongCredential of Response.t * Body.t [@@deriving sexp]

let get_auth_token () =
  let { username; password; uri } = Option.value_exn !conn in
  let body =
    Json.to_string (`Assoc [ "name", `String username; "password", `String password ])
    |> Body.of_string
  in
  let uri = Uri.with_path uri "/_session" in
  let%bind res, body =
    Client.post ~body ~headers:(Header.of_list [ "Content-Type", "application/json" ]) uri
  in
  match Response.status res with
  | `OK ->
    let header = Response.headers res in
    let token =
      Cookie.Set_cookie_hdr.extract header
      |> List.hd_exn
      |> snd
      |> Cookie.Set_cookie_hdr.value
    in
    return token
  | `Unauthorized -> raise (WrongCredential (res, body))
  | _ -> raise (UnexpectedResponse (res, body))
;;

let update_auth_token () =
  let%map c = get_auth_token () in
  auth_token := Some c
;;

let rec connect_with_auth f =
  let conn = Option.value_exn !conn in
  let%bind res, body =
    f conn (Header.of_list [ "Cookie", "AuthSession=" ^ Option.value_exn !auth_token ])
  in
  match Response.status res with
  | `Unauthorized ->
    let%bind _ = update_auth_token () in
    connect_with_auth f
  | _ -> return (res, body)
;;

let get_attachment db id filename =
  let path = id ^ "/" ^ filename in
  let%map res, body =
    connect_with_auth (fun conn auth_header ->
      Client.get ~headers:auth_header (Uri.with_path conn.uri ("/" ^ db ^ "/" ^ path)))
  in
  match Response.status res with
  | `OK -> Some (Body.to_pipe body)
  | `Not_found -> None
  | _ -> raise (UnexpectedResponse (res, body))
;;

let get_all db =
  let%bind res, body =
    connect_with_auth (fun conn auth_header ->
      Client.get ~headers:auth_header (Uri.with_path conn.uri ("/" ^ db ^ "/_all_docs")))
  in
  match Response.status res with
  | `OK ->
    let%bind body = body |> Body.to_string in
    return @@ Json.from_string body
  | _ -> raise (UnexpectedResponse (res, body))
;;

let get db id =
  let%bind res, body =
    connect_with_auth (fun conn auth_header ->
      Client.get ~headers:auth_header (Uri.with_path conn.uri ("/" ^ db ^ "/" ^ id)))
  in
  match Response.status res with
  | `OK ->
    let%bind body = body |> Body.to_string in
    return @@ Json.from_string body
  | _ -> raise (UnexpectedResponse (res, body))
;;

let json_to_body json = Body.of_string @@ Json.to_string json

(* Not used for now. *)
let add db doc =
  connect_with_auth (fun conn auth_header ->
    Client.post
      ~headers:(Header.add_list auth_header [ "Content-Type", "application/json" ])
      ~body:(json_to_body doc)
      (Uri.with_path conn.uri ("/" ^ db)))
;;

let find db select =
  let%bind res, body =
    connect_with_auth (fun conn auth_header ->
      Client.post
        ~headers:(Header.add_list auth_header [ "Content-Type", "application/json" ])
        ~body:(json_to_body select)
        (Uri.with_path conn.uri ("/" ^ db ^ "/_find")))
  in
  match Response.status res with
  | `OK ->
    let%map body = Body.to_string body in
    Json.Util.(body |> Json.from_string |> member "docs")
  | _ -> raise (UnexpectedResponse (res, body))
;;

let plates = "number_plates"
let users = "users"
