#include <mupdf/fitz.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "muchpdf.h"

int32_t render_input(uint8_t *const input, const size_t input_len, const double scale,
                     uint8_t **const rendered, size_t *const rendered_len) {
  fz_context *const ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
  if (!ctx) {
    return MUCHPDF_ERR;
  }

  fz_buffer *buffer = fz_new_buffer_from_data(ctx, input, input_len);

  fz_register_document_handlers(ctx);
  fz_document *document = fz_open_document_with_buffer(ctx, "application/octet-stream", buffer);

	fz_matrix affine = fz_scale(scale, scale);
	int page_number = 0;
	fz_colorspace *color_space = fz_device_rgb(ctx);
	int alpha = 0;
	fz_pixmap *pixmap = fz_new_pixmap_from_page_number(ctx, document, page_number, affine, color_space, alpha);

	fz_buffer *out_buf = fz_new_buffer(ctx, 1024);
	fz_output *out = fz_new_output_with_buffer(ctx, out_buf);
	fz_write_pixmap_as_png(ctx, out, pixmap);
	fz_close_output(ctx, out);

	*rendered_len = fz_buffer_extract(ctx, out_buf, rendered);

  fz_drop_output(ctx, out);
	fz_drop_pixmap(ctx, pixmap);
	fz_drop_document(ctx, document);
	fz_drop_context(ctx);

  return MUCHPDF_OK;
}
