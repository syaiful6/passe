let () = Mirage_crypto_rng_unix.use_getentropy ()
let generate n = Mirage_crypto_rng.generate n

let constant_time_equal a b =
  let len_a = String.length a in
  let len_b = String.length b in
  let result = ref (len_a lxor len_b) in
  let min_len = min len_a len_b in
  for i = 0 to min_len - 1 do
    result :=
      !result lor (Char.code (String.get a i) lxor Char.code (String.get b i))
  done;
  !result = 0
