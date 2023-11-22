open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  let%sub plates, set_plates =
    Bonsai.state_opt
      (module struct
        type t = Get_plates.plate list [@@deriving sexp, equal]
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
    let%bind.Effect plates = Get_plates.get () in
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
           ; Node.img
               ~attrs:
                 [ Attr.src @@ "/api/" ^ image
                 ; Attr.style
                     Css_gen.(height (`Px 80))
                 ]
               ()
           ])
  | None -> Node.text "Loading..."
;;
