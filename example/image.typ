#set page(width: 10cm, height: auto, margin: 0.5em)

#lorem(100)

#stack(
  dir: ltr,
  square(size: 2cm, fill: red),
  1cm,
  circle(radius: 1cm, fill: gradient.radial(..color.map.rainbow)),
)
