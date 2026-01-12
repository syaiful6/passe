#include "bcrypt.h"
#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

CAMLprim value passe_bcrypt_hashpass_stub(value key, value salt) {
  CAMLparam2(key, salt);
  CAMLlocal1(result);
  char encrypted[BCRYPT_HASHSPACE];
  int ret;

  if (!caml_string_is_c_safe(key)) {
    caml_invalid_argument("bcrypt: password contains null bytes");
  }

  if (!caml_string_is_c_safe(salt)) {
    caml_invalid_argument("bcrypt: salt contains null bytes");
  }

  ret = passe_bcrypt_hashpass(String_val(key), String_val(salt), encrypted,
                              sizeof(encrypted));
  if (ret != 0) {
    caml_failwith("bcrypt_hashpass failed");
  }

  result = caml_alloc_string(strlen(encrypted));
  memcpy((char *)String_val(result), encrypted, strlen(encrypted));
  CAMLreturn(result);
}

CAMLprim value passe_encode_base64_stub(value src) {
  CAMLparam1(src);
  CAMLlocal1(result);
  size_t src_len = caml_string_length(src);
  size_t dest_len = 4 * ((src_len + 2) / 3) + 1; // Base64 encoded length
  char *dest = (char *)malloc(dest_len);
  if (dest == NULL) {
    caml_failwith("Memory allocation failed");
  }

  int ret =
      passe_encode_base64(dest, (const u_int8_t *)String_val(src), src_len);
  if (ret != 0) {
    free(dest);
    caml_failwith("encode_base64 failed");
  }

  size_t encoded_len = strlen(dest);
  result = caml_alloc_string(encoded_len);
  memcpy((char *)String_val(result), dest, encoded_len);
  free(dest);
  CAMLreturn(result);
}
