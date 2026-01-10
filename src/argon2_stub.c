#include "argon2/argon2.h"
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

/* Maximum encoded hash length */
#define MAX_ENCODED_LEN 512

/* Hash a password with argon2id with provided salt */
CAMLprim value passe_argon2id_hash_encoded_with_salt_stub(
    value t_cost, value m_cost, value parallelism, value pwd, value salt) {
  CAMLparam5(t_cost, m_cost, parallelism, pwd, salt);
  CAMLlocal1(result);

  const uint32_t t = Int_val(t_cost);
  const uint32_t m = Int_val(m_cost);
  const uint32_t p = Int_val(parallelism);
  const char *password = String_val(pwd);
  const size_t pwdlen = caml_string_length(pwd);
  const char *salt_bytes = String_val(salt);
  const size_t saltlen = caml_string_length(salt);

  /* Default hash length of 32 bytes */
  const size_t hashlen = 32;

  /* Allocate buffer for encoded hash */
  char encoded[MAX_ENCODED_LEN];

  int ret = passe_argon2id_hash_encoded(t, m, p, password, pwdlen, salt_bytes,
                                        saltlen, hashlen, encoded,
                                        MAX_ENCODED_LEN);

  if (ret != ARGON2_OK) {
    result = caml_alloc_string(0);
  } else {
    result = caml_copy_string(encoded);
  }

  CAMLreturn(result);
}

/* Verify a password against an argon2id encoded hash */
CAMLprim value passe_argon2id_verify_stub(value encoded, value pwd) {
  CAMLparam2(encoded, pwd);

  const char *encoded_str = String_val(encoded);
  const char *password = String_val(pwd);
  const size_t pwdlen = caml_string_length(pwd);

  int ret = passe_argon2id_verify(encoded_str, password, pwdlen);

  CAMLreturn(Val_int(ret));
}
