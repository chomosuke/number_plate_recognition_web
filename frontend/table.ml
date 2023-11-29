open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  let%sub selected, set_selected =
    Bonsai.state_opt
      (module struct
        type t = int [@@deriving sexp, equal]
      end)
  in
  let%arr selected = selected
  and set_selected = set_selected in
  fun plates ->
    let open Vdom in
    match plates with
    | Some (Http.Plates plates) ->
      Node.table ~attrs:[ Attr.style Css_gen.(border_collapse `Collapse) ]
      @@ List.mapi plates ~f:(fun i ({ number; date_time; image } : Http.plate) ->
        let selected = Option.filter selected ~f:(( = ) i) |> is_some in
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
                   [ Attr.src @@ "/api/" ^ image
                   ; Attr.style Css_gen.(width (`Px (if selected then 500 else 200)))
                   ; Attr.on_click (fun _ ->
                       set_selected (if selected then None else Some i))
                   ]
                 ()
             ])
    | None -> Node.text "Loading..."
    | _ -> invalid_arg "Should not show table when Unauthorized."
;;
