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

sources = []
typst_sources = []
wasmer_sources = []

deps = []
deps += dependency('mupdf')

subdir('src')

common_link_args = [
  '-sSTANDALONE_WASM=1',
  '-sSUPPORT_LONGJMP=0',
]

shared_module(
  'muchpdf',
  sources: sources + typst_sources,
  dependencies: deps,
  install: true,
  link_args: common_link_args + [
    '--no-entry',
    '-sBINARYEN_EXTRA_PASSES=-Os'
  ],
  name_prefix: 'lib',
  name_suffix: 'wasm',
)

# Exists for debugging purposes.
executable(
  'muchpdf-wasmer',
  sources: sources + wasmer_sources,
  dependencies: deps,
  link_args: common_link_args + [
    '-g3',
  ],
  name_prefix: '',
  name_suffix: 'wasm',
)
