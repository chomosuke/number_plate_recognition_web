open! Core
open Bonsai_web

let component = Bonsai.const (Vdom.Node.text "Hello World!")
let () = Bonsai_web.Start.start component
