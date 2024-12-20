#set page(width: 12cm, height: auto, numbering: "1")

#set par(justify: true)
#lorem(100)

#grid(
  columns: (1fr, 1fr, 1fr),
  align: center + horizon,
  square(fill: green),
  circle(fill: gradient.radial(..color.map.rainbow)),
  image.decode(
    format: "svg",
    ```svg
    <?xml version="1.0" encoding="UTF-8"?>
    <svg width="2.5871cm" height="2.5351cm" version="1.1" viewBox="0 0 25.871 25.351" xmlns="http://www.w3.org/2000/svg">
     <g transform="translate(-6.8654 -6.4337)">
      <path transform="rotate(4.2427 -137.99 173.19)" d="m15.295 19.767-7.774-4.2771-7.9306 3.9793 1.6655-8.7152-6.2352-6.3128 8.8033-1.1092 4.077-7.8808 3.7753 8.0297 8.7549 1.4422-6.4701 6.0718z" fill="#17c9ee" stroke="#000" stroke-width=".26458"/>
     </g>
    </svg>
    ```.text,
  ),
)

#set page(fill: red.lighten(50%))
#lorem(20)

#set page(fill: yellow.lighten(50%))
#lorem(20)

#set page(fill: green.lighten(50%))
#lorem(20)

#set page(fill: blue.lighten(50%))
#lorem(20)
