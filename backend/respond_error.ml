open! Cohttp
open! Cohttp_async

let error_404 = "<html><body><h1>404 Not Found</h1></body></html>"
let respond_404 () = Server.respond_string ~status:`Not_found error_404
let error_405 = "<html><body><h1>405 Method Not Allowed</h1></body></html>"
let respond_405 () = Server.respond_string ~status:`Method_not_allowed error_405
