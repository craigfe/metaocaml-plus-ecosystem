let square x = x * x

let rec power_unspecialised : int -> int -> int =
 fun n x ->
  if n = 0 then 1
  else if n mod 2 = 0 then square (power_unspecialised (n / 2) x)
  else x * power_unspecialised (n - 1) x

let rec power : int -> int code -> int code =
 fun n x ->
  if n = 0 then .<1>.
  else if n mod 2 = 0 then .<square .~(power (n / 2) x)>.
  else (.<.~(x) * .~(power (n - 1) x)>.)

let spowern n = .<fun x -> .~(power n .<x>.)>.

let benchmark () =
  let perf (type a b) ~repeats (f : a -> b) (x : a) =
    let start_time = Sys.time () in
    for _ = 1 to repeats do
      ignore (f x : b)
    done;
    let result = f x in
    let elapsed_time = Sys.time () -. start_time in
    (result, elapsed_time)
  in
  let nb_runs = 100_000_000 in
  let n = 20 in
  let x = 2 in
  let result, time =
    let power_fn = power_unspecialised n in
    perf ~repeats:nb_runs power_fn x
  in
  Printf.printf
    "Unspecialized power %d ^ %d is %d                   – %g seconds\n%!" x n
    result time;
  let spower_fn, time =
    perf ~repeats:100 (fun () -> Runcode.run (spowern n)) ()
  in
  Printf.printf
    "Generated and compiled the specialized code (100 times) – %g seconds\n%!"
    time;
  let result, time = perf ~repeats:nb_runs spower_fn x in
  Printf.printf
    "Specialized power %d ^ %d is %d                     – %g seconds\n%!" x n
    result time

let () =
  assert (Runcode.run (spowern 7) 2 = 128);

  Format.printf
    "@[<v 0>Printing the specialised function (spowern 7): @,\
     @,\
    \  @[<v 2>let power7 =@,\
     %a@,\
     @]@]@."
    format_code
    (close_code (spowern 7));

  Format.printf "Running benchmarks:\n%!";
  benchmark ()
