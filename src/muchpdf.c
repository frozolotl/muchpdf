#include "emscripten.h"
#include <mupdf/fitz.h>

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#define PROTOCOL_FUNCTION __attribute__((import_module("typst_env"))) extern

PROTOCOL_FUNCTION void
wasm_minimal_protocol_send_result_to_host(const uint8_t *ptr, size_t len);
PROTOCOL_FUNCTION void wasm_minimal_protocol_write_args_to_buffer(uint8_t *ptr);

EMSCRIPTEN_KEEPALIVE
int32_t hello(void) {
  const char message[] = "Hello from wasm!!!";
  const size_t length = sizeof(message);
  wasm_minimal_protocol_send_result_to_host((const uint8_t *)message, length - 1);
  return 0;
}
