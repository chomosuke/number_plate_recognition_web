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

let get_plates =
  Effect_lwt.of_deferred_fun (fun () ->
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

let table =
  let%sub plates, set_plates =
    Bonsai.state_opt
      (module struct
        type t = plate list [@@deriving sexp, equal]
      end)
  in
  (* let%sub chosen_image, set_chosen_image = *)
  (*   Bonsai.state_opt *)
  (*     (module struct *)
  (*       type t = string [@@deriving sexp, equal] *)
  (*     end) *)
  (*     ~default_model:None *)
  (* in *)
  let%sub on_activate =
    let%arr set_plates =
      set_plates
      (* and chosen_image = chosen_image *)
      (* and set_chosen_image = set_chosen_image *)
    in
    let%bind.Effect plates = get_plates () in
    set_plates (Some plates)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  let%arr plates = plates in
  let open Vdom in
  match plates with
  | Some plates ->
    Node.table
    @@ List.map plates ~f:(fun { number; date_time; image } ->
      Node.tr
      @@ List.map
           ~f:(fun n -> Node.td [ n ])
           [ Node.text number
           ; Node.text date_time
           ; Node.img ~attrs:[ Attr.src @@ "/api/" ^ image ] ()
           ])
  | None -> Node.text "Loading..."
;;

let () = Bonsai_web.Start.start table
