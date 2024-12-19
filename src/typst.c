#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "emscripten.h"
#include "muchpdf.h"

#define PROTOCOL_FUNCTION __attribute__((import_module("typst_env"))) extern
#define TYPST_OK 0
#define TYPST_ERR 1

PROTOCOL_FUNCTION void
wasm_minimal_protocol_send_result_to_host(const uint8_t *ptr, size_t len);
PROTOCOL_FUNCTION void wasm_minimal_protocol_write_args_to_buffer(uint8_t *ptr);

EMSCRIPTEN_KEEPALIVE
int32_t render(const size_t input_len, const size_t scale_len) {
  assert(scale_len == 8);
  uint8_t *const input = (uint8_t *)malloc(input_len + scale_len);
  if (input == NULL) {
    return TYPST_ERR;
  }
  wasm_minimal_protocol_write_args_to_buffer(input);

  const double scale = *((double *)&input[input_len]);
  uint8_t *rendered;
  size_t rendered_len;
  const int32_t err =
      render_input(input, input_len, scale, &rendered, &rendered_len);
  if (err != MUCHPDF_OK) {
    return TYPST_ERR;
  }

  wasm_minimal_protocol_send_result_to_host(rendered, rendered_len);

  free(input);
  free(rendered);
  return TYPST_OK;
}
