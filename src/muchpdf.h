#include <stddef.h>
#include <stdint.h>
#include <uchar.h>

#define MUCHPDF_OK 0
#define MUCHPDF_ERR 1

typedef struct {
  uint32_t start;
  uint32_t end;
  uint32_t step;
} MuchPdfPageRange;

typedef struct {
  double scale;
  const MuchPdfPageRange *page_ranges;
  /// The number of ranges inside `page_ranges`.
  const size_t page_ranges_count;
} MuchPdfOptions;

typedef struct {
  uint8_t *data;
  size_t length;
} MuchPdfRenderedPage;

/// Render the input document and store the page list in `rendered`.
///
/// Takes ownership of `input`.
int32_t muchpdf_render_input(uint8_t *const input, const size_t input_len,
                             const MuchPdfOptions *options,
                             MuchPdfRenderedPage **const rendered,
                             size_t *const rendered_len,
                             const uint8_t **const error_message);
