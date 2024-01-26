open! Core
open! Async
open! Cohttp
open! Cohttp_async

val get : Cohttp_async.Body.t -> Request.t -> Server.response Deferred.t
