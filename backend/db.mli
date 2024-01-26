open! Core
open! Async
open! Cohttp
open! Cohttp_async
module Json = Yojson.Basic

type conn =
  { username : string
  ; password : string
  ; uri : Uri.t
  }

val set_conn : conn -> unit
val update_auth_token : unit -> unit Deferred.t
val get_attachment : string -> string -> string -> string Pipe.Reader.t option Deferred.t
val get_all : string -> Json.t Deferred.t
val get : string -> string -> Json.t Deferred.t
val add : string -> Json.t -> (Response.t * Cohttp_async.Body.t) Deferred.t
val find : string -> Json.t -> Json.t Deferred.t
val plates : string
val users : string
