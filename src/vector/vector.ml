let ( >> ) f g x = g (f x)

type ('i, 'a) vec = { length : 'i; prj : 'i -> 'a }
(** A generic input vector: pull vector *)

type ('i, 'a, 'w) ovec = { length : 'i; inj : 'i -> 'a -> 'w }
(** A generic output vector *)

(* To get a better feel for abstract vectors, let's see how OCaml
   arrays can be represented as a vector: actually, a pair of an
   input and an output vector.
*)

let vec_of_array : 'a array -> (int, 'a) vec * (int, 'a, unit) ovec =
 fun a ->
  let length = Array.length a in
  ({ length; prj = Array.get a }, { length; inj = Array.set a })

(* Truly generic function on vectors (element-wise) *)

let map : 'a 'b 'i. ('a -> 'b) -> ('i, 'a) vec -> ('i, 'b) vec =
 fun f v -> { v with prj = v.prj >> f }

let zip_with :
      'a 'b 'c 'i. ('a -> 'b -> 'c) -> ('i, 'a) vec -> ('i, 'b) vec ->
      ('i, 'c) vec =
 fun f v1 v2 -> { length = v1.length; prj = (fun i -> f (v1.prj i) (v2.prj i)) }

let vec_assign : 'a 'w 'i. ('i, 'a, 'w) ovec -> ('i, 'a) vec -> ('i, 'w) vec =
 fun output input ->
  { length = output.length; prj = (fun i -> output.inj i (input.prj i)) }

module type VEC = sig
  type index
  type unit

  val iter : (index, unit) vec -> unit
end

(* One implementation, for vectors representing ordinary arrays *)
module Vec_static = struct
  type idx = int
  type unt = unit

  let iter { length; prj } =
    for i = 1 to length do
      prj i
    done
end

(* int-code indexed vector: next-stage vectors *)
module Vec_dynamic = struct
  type idx = int code
  type unt = unit code

  let iter { length; prj } =
    .<for i = 1 to .~(length) do
        .~(prj .<i>.)
      done>.
end

(* ------------------------------------------------------------------------
   Very simple BLAS Level 1: vector assignment and element-wise multiplications
*)

(* Copied from [ring.ml], until there is a better story for linking. *)
module type RING = sig
  type t

  val zero : t
  val one : t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val ( * ) : t -> t -> t
end

(* Higher-level vector/matrix operations *)
module BLAS1 (R : RING) (A : VEC) = struct
  let ( := ) output input = A.iter (vec_assign output input)
  let ( *. ) v1 v2 = zip_with R.( * ) v1 v2 (* element-wise mul *)
end
