open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
module Json = Yojson.Basic

type plate =
  { number : string
  ; date_time : string
  ; image : string
  }
[@@deriving sexp, equal]

let get =
  Effect_lwt.of_deferred_fun (fun () ->
    print_endline "got plates";
    let open Lwt in
    let open Let_syntax in
    let%bind _, body = Cohttp_lwt_jsoo.Client.get (Uri.of_string "/api/plates") in
    let%map body = Cohttp_lwt.Body.to_string body >|= Json.from_string in
    let open Json.Util in
    body
    |> to_list
    |> List.map ~f:(fun plate ->
      { number = plate |> member "number" |> to_string
      ; date_time = plate |> member "dateTime" |> to_string
      ; image = plate |> member "image" |> to_string
      }))
;;
