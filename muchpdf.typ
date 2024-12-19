#let pdf-img = {
  let muchpdf-plugin = plugin("./result/lib/libmuchpdf.wasm")

  let pdf-img(data, scale: 2.0, ..args) = {
    assert.eq(type(data), bytes)
    let rendered = muchpdf-plugin.render(data, float.to-bytes(scale))
    image.decode(rendered, format: "svg", ..args)
  }

  pdf-img
}
