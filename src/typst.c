#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "emscripten.h"
#include "muchpdf.h"

// HACK: Prevent clangd from complaining.
#ifndef EMSCRIPTEN_KEEPALIVE
#define EMSCRIPTEN_KEEPALIVE
#endif

#define PROTOCOL_FUNCTION __attribute__((import_module("typst_env"))) extern
#define TYPST_OK 0
#define TYPST_ERR 1

PROTOCOL_FUNCTION void
wasm_minimal_protocol_send_result_to_host(const uint8_t *ptr, size_t len);
PROTOCOL_FUNCTION void wasm_minimal_protocol_write_args_to_buffer(uint8_t *ptr);

static void muchpdf_serialize_output(const MuchPdfRenderedPage *const rendered,
                                     const size_t rendered_len,
                                     uint8_t **const output,
                                     size_t *const output_len) {
  *output_len = 0;
  for (size_t i = 0; i < rendered_len; ++i) {
    *output_len += sizeof(uint64_t) + rendered[i].length;
  }

  *output = malloc(*output_len * sizeof(uint8_t));
  uint8_t *cursor = *output;
  for (size_t i = 0; i < rendered_len; ++i) {
    uint64_t length = rendered[i].length;
    memcpy(cursor, &length, sizeof(uint64_t));
    cursor += sizeof(uint64_t);
    memcpy(cursor, rendered[i].data, length);
    cursor += length;
  }
}

EMSCRIPTEN_KEEPALIVE
int32_t render(const size_t input_len, const size_t scale_len,
               const size_t page_ranges_len) {
  assert(scale_len == 8);
  uint8_t *const input = malloc(input_len + scale_len + page_ranges_len);
  if (input == NULL) {
    return TYPST_ERR;
  }
  wasm_minimal_protocol_write_args_to_buffer(input);

  double scale;
  memcpy(&scale, &input[input_len], sizeof(double));

  MuchPdfPageRange *page_ranges = malloc(page_ranges_len);
  memcpy(page_ranges, &input[input_len + scale_len], page_ranges_len);
  
  const MuchPdfOptions options = {
      .scale = scale,
      .page_ranges = page_ranges,
      .page_ranges_count = page_ranges_len / sizeof(MuchPdfPageRange),
  };
  MuchPdfRenderedPage *rendered;
  size_t rendered_len;
  const int32_t err = muchpdf_render_input(input, input_len, &options,
                                           &rendered, &rendered_len);
  if (err != MUCHPDF_OK) {
    return TYPST_ERR;
  }

  uint8_t *output;
  size_t output_len;
  muchpdf_serialize_output(rendered, rendered_len, &output, &output_len);
  
  free(input);
  for (size_t i = 0; i < rendered_len; ++i) {
    free(rendered[i].data);
  }
  free(rendered);

  wasm_minimal_protocol_send_result_to_host(output, output_len);

  free(output);
  return TYPST_OK;
}
