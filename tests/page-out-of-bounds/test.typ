#import "../../lib.typ": muchpdf

#let data = read("../../test-assets/document.pdf", encoding: none)

#assert.eq(
  catch(() => muchpdf(data, pages: 5)).first(),
  "plugin errored with: page number out of bounds",
)
