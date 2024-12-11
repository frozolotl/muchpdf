#import "../muchpdf.typ": pdf-img

#rect[
  #pdf-img(read("image.pdf", encoding: none))
]
