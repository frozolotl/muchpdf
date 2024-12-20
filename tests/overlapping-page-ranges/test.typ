#import "../../lib.typ": muchpdf

#let data = read("../../test-assets/document.pdf", encoding: none)

#muchpdf(data, pages: ((start: 0, end: 2), (start: 1, end: 3), (:)))
