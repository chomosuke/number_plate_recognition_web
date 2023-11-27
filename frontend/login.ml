open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  Computation.return (fun on_login ->
    let open Vdom in
    Node.button
      ~attrs:
        [ Attr.on_click (fun _ ->
            on_login ({ username = "admin"; password = "password" } : Http.login))
        ]
      [ Node.text "login" ])
;;
