open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  let%sub plates, set_plates =
    Bonsai.state_opt
      (module struct
        type t = Http.plates [@@deriving sexp, equal]
      end)
  in
  let fetch_plates () =
    let%map set_plates = set_plates in
    let%bind.Effect plates = Http.get_plates () in
    set_plates (Some plates)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate:(fetch_plates ()) () in
  let on_login =
    let%map fetch_plates = fetch_plates () in
    fun login ->
      let%bind.Effect _ = Http.login login in
      fetch_plates
  in
  let%sub table = Table.component in
  let%sub login = Login.component in
  let%arr table = table
  and plates = plates
  and login = login
  and on_login = on_login in
  let open Vdom in
  match plates with
  | None | Some (Plates _) ->
    Node.div
      ~attrs:
        [ Attr.style
            Css_gen.(margin ~left:`Auto ~right:`Auto () @> width (`Raw "fit-content"))
        ]
      [ table plates ]
  | Some Unauthorized ->
    Node.div
      ~attrs:
        [ Attr.style
            Css_gen.(
              of_string_css_exn
                " display: flex;  justify-content: center;  align-items: center;  \
                 text-align: center;  min-height: 100vh;")
        ]
      [ Node.div
          ~attrs:[ Attr.style Css_gen.(margin ~top:`Auto ~bottom:`Auto ()) ]
          [ login on_login ]
      ]
;;
