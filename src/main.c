#include "muchpdf.h"

uint8_t input[] = {
#embed "../example/image.pdf"
};

int main() {
  uint8_t *rendered;
  size_t rendered_len;
  return render_input(input, sizeof(input), 2.0, &rendered, &rendered_len);
}
