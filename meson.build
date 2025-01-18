project(
  'muchpdf',
  'c',
  version: '0.1.0',
  default_options: [
    'c_std=c23',
    'warning_level=3',
    'optimization=s',
    'debug=false',
  ],
)

deps = []
deps += dependency('mupdf')

sources = []
subdir('src')

common_link_args = [
  '-sSTANDALONE_WASM=1',
  '-sSUPPORT_LONGJMP=0',
]

shared_module(
  'muchpdf',
  sources: sources,
  dependencies: deps,
  install: true,
  link_args: common_link_args + [
    '--no-entry',
    '-sBINARYEN_EXTRA_PASSES=-Os',
    '-sSTACK_SIZE=1048576'
  ],
  name_prefix: '',
  name_suffix: 'wasm',
)
