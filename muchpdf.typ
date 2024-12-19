#let pdf-img = {
  let muchpdf-plugin = plugin("./result/lib/libmuchpdf.wasm")

  let pdf-img(data, scale: 2.0, ..args) = {
    assert.eq(type(data), bytes)
    let rendered = muchpdf-plugin.render(data, float.to-bytes(scale))
    let height = int.from-bytes(
      rendered.slice(0, 4),
      endian: "little",
      signed: false,
    )
    let pixels = rendered.slice(4)
    let n-components = 3
    let width = int(pixels.len() / height / n-components)
    let pixmap = (
      data: pixels,
      pixel-width: width,
      pixel-height: height,
    )
    image.decode(pixmap, format: "rgb8", ..args)
  }

  pdf-img
}
