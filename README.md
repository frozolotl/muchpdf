# MuchPDF

MuchPDF allows you to insert PDF files as images into your Typst document.

Huge thanks to the contributors of the [MuPDF][MuPDF] library,
without which this project would not be possible!

## Usage

It is easy to use:

```typ
#import "@preview/muchpdf:0.1.0": muchpdf

#muchpdf(read("graphic.pdf", encoding: none))
```

You can increase the scale, if desired:

```typ
#muchpdf(
  read("graphic.pdf", encoding: none),
  scale: 2.0,
)
```

The parameters provided by [image][image] do also work as expected:

```typ
#muchpdf(
  read("dolphins.pdf", encoding: none),
  width: 10cm,
  alt: "Dolphin population over time",
)
```

## Questions

> I'm getting the following error message:
> ```
> error: plugin panicked: wasm `unreachable` instruction executed
> ```

This most likely means that the PDF file you supplied is not valid.
If you disagree with that assessment, do please open an issue on the [Issue Tracker][Issue Tracker].

> Why is that error message so bad?

That's because of how hacky MuchPDF actually is. It overrides a number of
functions supplied by emscripten, which includes part of the error handling.
I don't think I can do much about it without significant time investments.

> My beautiful gradients are pixelated in the output. :(

MuPDF rasterizes some things in its SVG output, which does include gradients.
This is to be expected and there isn't much MuchPDF or MuPDF can do about it.
Increasing the scale parameter might lessen the impact of this, though.

[MuPDF]: https://mupdf.com/
[image]: https://typst.app/docs/reference/visualize/image/
[Issue Tracker]: https://github.com/frozolotl/muchpdf/issues
