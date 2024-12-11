project(
  'muchpdf',
  'c',
  version: '0.1.0',
  default_options: ['c_std=c23', 'warning_level=3', 'optimization=s', 'buildtype=debug'],
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
    '--no-entry',
    '-sSTANDALONE_WASM=1',
    '-sSUPPORT_LONGJMP=0',
    '-sDETERMINISTIC=1',
  ],
  name_prefix: 'lib',
  name_suffix: 'wasm',
)
