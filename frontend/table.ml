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
  let%sub on_activate =
    let%arr set_plates = set_plates in
    let%bind.Effect plates = Get_plates.get () in
    set_plates (Some plates)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  let%arr plates = plates in
  let open Vdom in
  match plates with
  | Some plates ->
    Node.table ~attrs:[ Attr.style Css_gen.(border_collapse `Collapse) ]
    @@ List.map plates ~f:(fun { number; date_time; image } ->
      Node.tr
      @@ List.map
           ~f:(fun n ->
             Node.td
               ~attrs:
                 [ Attr.style
                     Css_gen.(
                       padding
                         ~top:(`Px 5)
                         ~bottom:(`Px 5)
                         ~left:(`Px 10)
                         ~right:(`Px 10)
                         ()
                       @> border ~style:`Solid ~width:(`Px 1) ())
                 ]
               [ n ])
           [ Node.text number
           ; Node.text date_time
           ; Node.img
               ~attrs:
                 [ Attr.src @@ "/api/" ^ image; Attr.style Css_gen.(height (`Px 80)) ]
               ()
           ])
  | None -> Node.text "Loading..."
;;
