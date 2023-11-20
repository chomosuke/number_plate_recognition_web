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
    let header =
      Header.add_multi header "set-cookie" @@ Header.get_multi header "Set-Cookie"
    in
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

let rec query path =
  let conn = Option.value_exn !conn in
  let%bind res, body =
    Client.get
      ~headers:
        (Header.of_list [ "Cookie", "AuthSession=" ^ Option.value_exn !auth_token ])
      (Uri.with_path conn.uri path)
  in
  match Response.status res with
  | `Unauthorized ->
    let%bind _ = update_auth_token () in
    query path
  | `OK ->
    let%bind body = Body.to_string body in
    return @@ Json.from_string body
  | _ -> raise (UnexpectedResponse (res, body))
;;
