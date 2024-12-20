#include <mupdf/fitz.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "muchpdf.h"

typedef struct {
  fz_context *context;
  fz_buffer *input;
  fz_document *document;
  fz_matrix affine;
  fz_cookie cookie;
} MuchPdfContext;

static int32_t muchpdf_context_init(uint8_t *const input,
                                    const size_t input_len,
                                    const MuchPdfOptions *options,
                                    MuchPdfContext *const ctx) {
  ctx->context = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
  if (!ctx->context) {
    return MUCHPDF_ERR;
  }

  ctx->input = fz_new_buffer_from_data(ctx->context, input, input_len);

  fz_register_document_handlers(ctx->context);
  ctx->document =
      fz_open_document_with_buffer(ctx->context, "application/pdf", ctx->input);

  ctx->affine = fz_scale(options->scale, options->scale);

  memset(&ctx->cookie, 0, sizeof(fz_cookie));

  return MUCHPDF_OK;
}

static void muchpdf_context_drop(MuchPdfContext *const ctx) {
  fz_drop_document(ctx->context, ctx->document);
  fz_drop_buffer(ctx->context, ctx->input);
  fz_drop_context(ctx->context);
}

static void muchpdf_render_page(MuchPdfContext *const ctx, fz_page *const page,
                                MuchPdfRenderedPage *const rendered) {
  fz_buffer *const out_buf = fz_new_buffer(ctx->context, 1024);
  fz_output *const out = fz_new_output_with_buffer(ctx->context, out_buf);

  const fz_rect mediabox = fz_bound_page_box(ctx->context, page, FZ_CROP_BOX);
  const fz_rect page_bounds = fz_transform_rect(mediabox, ctx->affine);
  const float page_width = page_bounds.x1 - page_bounds.x0;
  const float page_height = page_bounds.y1 - page_bounds.y0;
  const int reuse_images = 1;
  fz_device *const device =
      fz_new_svg_device(ctx->context, out, page_width, page_height,
                        FZ_SVG_TEXT_AS_PATH, reuse_images);
  fz_run_page(ctx->context, page, device, ctx->affine, &ctx->cookie);

  fz_close_device(ctx->context, device);
  fz_close_output(ctx->context, out);

  rendered->length = fz_buffer_extract(ctx->context, out_buf, &rendered->data);
}

static void muchpdf_count_pages(const MuchPdfContext *const ctx,
                                    const MuchPdfOptions *const options,
                                  uint32_t *const input_count,
                                uint32_t *const output_count) {
  *input_count = fz_count_pages(ctx->context, ctx->document);

  uint32_t count = 0;
  for (size_t i = 0; i < options->page_ranges_count; ++i) {
    MuchPdfPageRange range = options->page_ranges[i];
    if (range.end == UINT32_MAX) {
      range.end = *input_count - 1;
    }
    count += (range.end - range.start) / range.step;
  }
  *output_count = count;
}

int32_t muchpdf_render_input(uint8_t *const input, const size_t input_len,
                             const MuchPdfOptions *options,
                             MuchPdfRenderedPage **const rendered,
                             size_t *const rendered_len) {
  MuchPdfContext ctx;
  const int32_t res = muchpdf_context_init(input, input_len, options, &ctx);
  if (res != MUCHPDF_OK) {
    return res;
  }

  uint32_t input_page_count, output_page_count;
  muchpdf_count_pages(&ctx, options, &input_page_count, &output_page_count);
  MuchPdfRenderedPage *const rendered_pages =
      malloc(output_page_count * sizeof(MuchPdfRenderedPage));
  size_t rendered_pages_idx = 0;

  for (size_t i = 0; i < options->page_ranges_count; ++i) {
    MuchPdfPageRange range = options->page_ranges[i];
    if (range.end == UINT32_MAX) {
      range.end = input_page_count - 1;
    }
    for (uint32_t page_number = range.start; page_number <= range.end;
         page_number += range.step) {
      fz_page *page = fz_load_page(ctx.context, ctx.document, page_number);
      muchpdf_render_page(&ctx, page, &rendered_pages[rendered_pages_idx]);
      ++rendered_pages_idx;
    }
  }

  muchpdf_context_drop(&ctx);

  *rendered = rendered_pages;
  *rendered_len = rendered_pages_idx;

  return MUCHPDF_OK;
}
