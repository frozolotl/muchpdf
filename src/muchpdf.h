#include <stddef.h>
#include <stdint.h>

#define MUCHPDF_OK 0
#define MUCHPDF_ERR 1

int32_t render_input(uint8_t *const input, const size_t input_len, const double scale,
                     uint8_t **const rendered, size_t *const rendered_len);
