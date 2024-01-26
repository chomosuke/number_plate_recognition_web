open! Core
open! Async
open! Cohttp
open! Cohttp_async

val error_404 : string
val respond_404 : unit -> Server.response Deferred.t
val error_405 : string
val respond_405 : unit -> Server.response Deferred.t
val error_400 : string
val respond_400 : unit -> Server.response Deferred.t
val error_401 : string
val respond_401 : unit -> Server.response Deferred.t
