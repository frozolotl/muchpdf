project(
  'muchpdf',
  'c',
  version: '0.1.0',
  default_options: [
    'c_std=c23',
    'warning_level=3',
    'optimization=s',
    'buildtype=debug',
  ],
)

sources = []
typst_sources = []
wasmer_sources = []

deps = []
deps += dependency('mupdf')

subdir('src')

shared_module(
  'muchpdf',
  sources: sources + typst_sources,
  dependencies: deps,
  install: true,
  link_args: [
    '--no-entry',
    '-sSTANDALONE_WASM=1',
    '-sSUPPORT_LONGJMP=0',
  ],
  name_prefix: 'lib',
  name_suffix: 'wasm',
)

executable(
  'muchpdf-wasmer',
  sources: sources + wasmer_sources,
  dependencies: deps,
  link_args: [
    '-sSTANDALONE_WASM=1',
    '-sSUPPORT_LONGJMP=0',
    '-g3',
  ],
  name_prefix: '',
  name_suffix: 'wasm',
)
