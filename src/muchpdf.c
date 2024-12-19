#include <mupdf/fitz.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "muchpdf.h"

int32_t render_input(uint8_t *const input, const size_t input_len,
                     const double scale, uint8_t **const rendered,
                     size_t *const rendered_len) {
  fz_context *const ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
  if (!ctx) {
    return MUCHPDF_ERR;
  }

  fz_buffer *buffer = fz_new_buffer_from_data(ctx, input, input_len);

  fz_register_document_handlers(ctx);
  fz_document *document =
      fz_open_document_with_buffer(ctx, "application/pdf", buffer);

  fz_buffer *out_buf = fz_new_buffer(ctx, 1024);
  fz_output *out = fz_new_output_with_buffer(ctx, out_buf);

  fz_cookie cookie = {0};

  fz_matrix affine = fz_scale(scale, scale);
  const int page_number = 0;
  fz_page *page = fz_load_page(ctx, document, page_number);
  fz_rect mediabox = fz_bound_page_box(ctx, page, FZ_CROP_BOX);
  fz_rect page_bounds = fz_transform_rect(mediabox, affine);
  const float page_width = page_bounds.x1 - page_bounds.x0;
  const float page_height = page_bounds.y1 - page_bounds.y0;
  const int reuse_images = 1;
  fz_device *device = fz_new_svg_device(ctx, out, page_width, page_height,
                                        FZ_SVG_TEXT_AS_PATH, reuse_images);
  fz_run_page(ctx, page, device, affine, &cookie);

  fz_close_device(ctx, device);
  fz_close_output(ctx, out);

  *rendered_len = fz_buffer_extract(ctx, out_buf, rendered);

  fz_drop_device(ctx, device);
  fz_drop_page(ctx, page);
  fz_drop_output(ctx, out);
  fz_drop_document(ctx, document);
  fz_drop_buffer(ctx, buffer);
  fz_drop_context(ctx);

  return MUCHPDF_OK;
}
