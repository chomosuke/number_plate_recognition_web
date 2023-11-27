open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
module Json = Yojson.Basic
open! Lwt
open! Let_syntax

exception UnexpectedResponse of Cohttp_lwt.Response.t * Cohttp_lwt.Body.t
[@@deriving sexp]

type plate =
  { number : string
  ; date_time : string
  ; image : string
  }
[@@deriving sexp, equal]

type plates =
  | Plates of plate list
  | Unauthorized
[@@deriving sexp, equal]

let get_plates =
  Effect_lwt.of_deferred_fun (fun () ->
    let%bind res, body = Cohttp_lwt_jsoo.Client.get (Uri.of_string "/api/plates") in
    match Cohttp_lwt.Response.status res with
    | `OK ->
      let%map body = Cohttp_lwt.Body.to_string body >|= Json.from_string in
      let open Json.Util in
      Plates
        (body
         |> to_list
         |> List.map ~f:(fun plate ->
           { number = plate |> member "number" |> to_string
           ; date_time = plate |> member "dateTime" |> to_string
           ; image = plate |> member "image" |> to_string
           }))
    | `Unauthorized -> return Unauthorized
    | _ -> raise (UnexpectedResponse (res, body)))
;;

type login =
  { username : string
  ; password : string
  }

let login =
  Effect_lwt.of_deferred_fun (fun { username; password } ->
    let%map res, body =
      Cohttp_lwt_jsoo.Client.post
        ~body:
          (`Assoc [ "username", `String username; "password", `String password ]
           |> Json.to_string
           |> Cohttp_lwt.Body.of_string)
        (Uri.of_string "/api/login")
    in
    match res |> Cohttp_lwt.Response.status with
    | `OK -> true
    | `Unauthorized -> false
    | _ -> raise (UnexpectedResponse (res, body)))
;;
