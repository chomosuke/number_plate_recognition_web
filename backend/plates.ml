open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic

let transform_doc doc =
  Json.Util.(
    `Assoc
      [ "number", `String (doc |> member "numberplate" |> to_string)
      ; ( "dateTime"
        , `String
            ((doc |> member "date" |> to_string)
             ^ "T"
             ^ (doc |> member "time" |> to_string)) )
      ; ( "image"
        , `String
            ("image/"
             ^ (doc |> member "_id" |> to_string)
             ^ "/"
             ^ (doc |> member "_attachments" |> to_assoc |> List.hd_exn |> fst)) )
      ])
;;

let get _body _req =
  let%bind all_docs = Db.get_all Db.plates in
  let doc_ids =
    Json.Util.(
      member "rows" all_docs
      |> to_list
      |> List.map ~f:(fun doc -> doc |> member "id" |> to_string))
  in
  let%bind docs = List.map doc_ids ~f:(fun id -> Db.get Db.plates id) |> Deferred.all in
  let docs = `List (List.map docs ~f:transform_doc) in
  Server.respond_string (Json.to_string docs)
;;
