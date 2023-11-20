open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic
open! Json.Util

let get _body _req =
  let%bind all_docs = Db.query "/number_plates/_all_docs" in
  let doc_ids =
    member "rows" all_docs
    |> to_list
    |> List.map ~f:(fun doc -> doc |> member "id" |> to_string)
  in
  let%bind docs =
    List.map doc_ids ~f:(fun id -> Db.query ("/number_plates/" ^ id)) |> Deferred.all
  in
  let docs = `List docs in
  Server.respond_string (Json.to_string docs)
;;
