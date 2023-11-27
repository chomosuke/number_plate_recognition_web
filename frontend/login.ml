open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  let%sub username, set_username =
    Bonsai.state
      (module struct
        type t = string [@@deriving sexp, equal]
      end)
      ~default_model:""
  in
  let%sub password, set_password =
    Bonsai.state
      (module struct
        type t = string [@@deriving sexp, equal]
      end)
      ~default_model:""
  in
  let%arr username = username
  and set_username = set_username
  and password = password
  and set_password = set_password in
  fun on_login ->
    let open Vdom in
    Node.div
      [ Node.text "username: "
      ; Node.input
          ~attrs:
            [ Attr.on_change (fun _ str -> set_username str)
            ; Attr.style Css_gen.(margin ~bottom:(`Px 30) ())
            ]
          ()
      ; Node.br ()
      ; Node.text "password: "
      ; Node.input
          ~attrs:
            [ Attr.on_change (fun _ str -> set_password str)
            ; Attr.style Css_gen.(margin ~bottom:(`Px 30) ())
            ]
          ()
      ; Node.br ()
      ; Node.button
          ~attrs:
            [ Attr.on_click (fun _ -> on_login ({ username; password } : Http.login)) ]
          [ Node.text "login" ]
      ]
;;
