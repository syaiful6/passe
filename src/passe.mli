type hash = Hash.t
(** A hashed password. This represent a password that has been put through
 a hashing function. *)

val hash_to_string : hash -> string
(** [hash_to_string h] converts the hash [h] to its string representation *)

val hash_of_string : string -> hash
(** [hash_of_string s] convert the string to its hash representation, this
 function must only be used when you know your string is the result of previous
 operation, eg when you get the string from database. *)

module Bcrypt = Bcrypt
(** The bcrypt hashing algorithm. *)

module Argon2 = Argon2
(** The argon2 hashing algorithm. *)
