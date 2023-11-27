open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  Computation.return (fun plates ->
    let open Vdom in
    match plates with
    | Some (Http.Plates plates) ->
      Node.table ~attrs:[ Attr.style Css_gen.(border_collapse `Collapse) ]
      @@ List.map plates ~f:(fun ({ number; date_time; image } : Http.plate) ->
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
    | _ -> invalid_arg "Should not show table when Unauthorized.")
;;
