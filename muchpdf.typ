#let pdf-img = {
  let muchpdf-plugin = plugin("./result/lib/libmuchpdf.wasm")

  let pdf-img(data, ..args) = {
    assert.eq(type(data), bytes)
    [#data]
    [#muchpdf-plugin.render(data)]
  }

  pdf-img
}
