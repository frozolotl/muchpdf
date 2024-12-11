#include <mupdf/fitz.h>
#include <setjmp.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "emscripten.h"

#define PROTOCOL_FUNCTION __attribute__((import_module("typst_env"))) extern
#define TYPST_OK 0
#define TYPST_ERR 1

PROTOCOL_FUNCTION void
wasm_minimal_protocol_send_result_to_host(const uint8_t *ptr, size_t len);
PROTOCOL_FUNCTION void wasm_minimal_protocol_write_args_to_buffer(uint8_t *ptr);

EMSCRIPTEN_KEEPALIVE
int32_t render(const size_t input_len) {
  uint8_t *const input = (uint8_t *)malloc(input_len);
  if (!input) {
    return TYPST_ERR;
  }
  wasm_minimal_protocol_write_args_to_buffer(input);

  fz_context *const ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
  if (!ctx) {
    return TYPST_ERR;
  }

  wasm_minimal_protocol_send_result_to_host(input, input_len);

  free(input);
  return TYPST_ERR;
}

__attribute__((import_module("env"))) int setjmp(jmp_buf) { return 0; }
__attribute__((import_module("env"))) void longjmp(jmp_buf, int) {
  abort();
}

typedef struct ResultTimestamp {
  uint32_t tag;
  uint64_t timestamp;
} ResultTimestamp;

__attribute__((import_module("wasi_snapshot_preview1"))) int32_t
clock_time_get(int32_t, int64_t, ResultTimestamp *time_out) {
  const ResultTimestamp time = {.tag = 0, .timestamp = 0};
  *time_out = time;

  return 0;
}
