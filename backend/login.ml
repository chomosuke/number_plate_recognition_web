open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic

let post body _req =
  let%bind body = Body.to_string body in
  let body =
    try
      Some
        Json.Util.(
          let json = Json.from_string body in
          json |> member "username" |> to_string, json |> member "password" |> to_string)
    with
    | Yojson.Json_error _ -> None
    | Json.Util.Type_error _ -> None
    | exn -> raise exn
  in
  match body with
  | Some (username, password) ->
    let%bind found =
      Db.find
        Db.users
        (`Assoc
          [ "selector", `Assoc [ "username", `String username ]
          ; "fields", `List [ `String "password" ]
          ])
    in
    let open Json.Util in
    (match found |> to_list |> List.hd with
     | Some found ->
       if found
          |> member "password"
          |> to_string
          |> Bcrypt.hash_of_string
          |> Bcrypt.verify password
       then (
         let token =
           Json.to_string
             (`Assoc [ "username", `String username; "created", `Float (Unix.time ()) ])
           |> Aes.encrypt
         in
         Server.respond_string
           ~headers:
             (Header.of_list
                [ "Set-Cookie", "Auth=" ^ token ^ "; Max-Age=2630000" (* 1 month *) ])
           "OK")
       else Respond_error.respond_401 ()
     | None -> Respond_error.respond_401 ())
  | None -> Respond_error.respond_400 ()
;;
