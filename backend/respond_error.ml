open! Core
open! Async
open! Cohttp
open! Cohttp_async

let error_404 = "<html><body><h1>404 Not Found</h1></body></html>"
let respond_404 () = Server.respond_string ~status:`Not_found error_404
let error_405 = "<html><body><h1>405 Method Not Allowed</h1></body></html>"
let respond_405 () = Server.respond_string ~status:`Method_not_allowed error_405
let error_400 = "<html><body><h1>400 Bad Request</h1></body></html>"
let respond_400 () = Server.respond_string ~status:`Bad_request error_400
let error_401 = "<html><body><h1>401 Unauthorized</h1></body></html>"
let respond_401 () = Server.respond_string ~status:`Unauthorized error_401
