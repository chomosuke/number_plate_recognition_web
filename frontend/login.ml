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
  let%sub failed, set_failed =
    Bonsai.state
      (module struct
        type t = bool [@@deriving sexp, equal]
      end)
      ~default_model:false
  in
  let%arr username = username
  and set_username = set_username
  and password = password
  and set_password = set_password
  and failed = failed
  and set_failed = set_failed in
  fun on_login ->
    let open Vdom in
    Node.div
      [ Node.div
          [ Node.text "username: "
          ; Node.input
              ~attrs:
                [ Attr.on_change (fun _ str -> set_username str)
                ; Attr.style Css_gen.(margin ~bottom:(`Px 20) ())
                ]
              ()
          ]
      ; Node.div
          [ Node.text "password: "
          ; Node.input
              ~attrs:
                [ Attr.on_change (fun _ str -> set_password str)
                ; Attr.type_ "password"
                ; Attr.style Css_gen.(margin ~bottom:(`Px 20) ())
                ]
              ()
          ]
      ; Node.button
          ~attrs:
            [ Attr.on_click (fun _ ->
                let open Effect.Let_syntax in
                let d =
                  if failed
                  then (
                    let%bind _ = set_failed false in
                    Bonsai_web.Effect.of_deferred_fun
                      (fun () -> Async_kernel.after (Time_ns.Span.of_sec 0.2))
                      ())
                  else return ()
                in
                let%bind success, _ =
                  Let_syntax.both (Http.login { username; password }) d
                in
                if success then on_login else set_failed true)
            ]
          [ Node.text "login" ]
      ; Node.div
          ~attrs:[ Attr.style Css_gen.(color (`Name "red")) ]
          [ Node.text (if failed then "username or password incorrect" else "") ]
      ]
;;
