open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component =
  let%sub table = Table.component in
  let%arr table = table in
  let open Vdom in
  Node.div
    ~attrs:
      [ Attr.style
          Css_gen.(margin ~left:`Auto ~right:`Auto () @> width (`Raw "fit-content"))
      ]
    [ table ]
;;
