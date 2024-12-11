project(
  'muchpdf',
  'c',
  version: '0.1.0',
  default_options: ['c_std=c23', 'warning_level=3', 'optimization=3'],
)

sources = []
deps = []
deps += dependency('mupdf')

subdir('src')

shared_module(
  'muchpdf',
  sources: sources,
  dependencies: deps,
  install: true,
  link_args: [
    '-sSTANDALONE_WASM=1',
    '-sMAIN_MODULE=2',
  ],
  name_prefix: 'lib',
  name_suffix: 'wasm',
)
