#let pdf-img = {
  let muchpdf-plugin = plugin("./result/lib/libmuchpdf.wasm")

  let pdf-img(data, ..args) = {
    assert.eq(type(data), bytes)
    image.decode(muchpdf-plugin.render(data), format: "png")
  }

  pdf-img
}
