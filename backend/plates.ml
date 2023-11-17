open! Core
open! Async
open! Cohttp
open! Cohttp_async

let get _body _req = Server.respond_string "Hey there"
