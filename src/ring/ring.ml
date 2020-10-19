module type Ring = sig
  type t

  val zero : t
  val one : t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val ( * ) : t -> t -> t
end

let xsq1 (type a) : (module Ring with type t = a) -> a -> a =
 fun (module R) x -> R.((x * x) + one)

module Float_ring : Ring with type t = float = struct
  type t = float
  (** Not quite a ring thanks to imprecision, but good enough... *)

  let zero = 0.
  let one = 1.
  let ( + ) = ( +. )
  let ( - ) = ( -. )
  let ( * ) = ( *. )
end

let () = assert (xsq1 (module Float_ring) 2.0 = 5.0)

(** [Float_ring] lifted to [code] values *)
module Float_code_ring : Ring with type t = float code = struct
  type t = float code

  let zero = .<0.>.
  let one = .<1.>.
  let ( + ) x y = .<.~(x) +. .~(y)>.
  let ( - ) x y = .<.~(x) -. .~(y)>.
  let ( * ) x y = .<.~(x) *. .~(y)>.
end

let (_ : _ code) =
  let f = xsq1 (module Float_code_ring) in
  .<fun x -> .~(f .<x>.)>.

let () =
  let f = xsq1 (module Float_code_ring) in
  assert (Runcode.run .<fun x -> .~(f .<x>.)>. 2.0 = 5.0)
