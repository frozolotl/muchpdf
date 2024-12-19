#let muchpdf = {
  let muchpdf-plugin = plugin("muchpdf.wasm")

  let muchpdf(data, scale: 2.0, ..args) = {
    assert.eq(type(data), bytes)
    let rendered = muchpdf-plugin.render(data, float.to-bytes(scale))
    image.decode(rendered, format: "svg", ..args)
  }

  muchpdf
}
