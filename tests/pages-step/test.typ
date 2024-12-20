#import "../../lib.typ": muchpdf

#let data = read("../../test-assets/document.pdf", encoding: none)

#muchpdf(data, pages: (step: 2))
#muchpdf(data, pages: (step: 3))
