val set_secret : string -> unit
val encrypt : ?padding:Cstruct.byte -> string -> string
val decrypt : string -> string option
