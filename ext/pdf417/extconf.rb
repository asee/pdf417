require 'mkmf'

# lib/pdf417.rb loads the compiled extension with `require 'pdf417/pdf417'`,
# so the Makefile target needs the pdf417/ prefix. The upstream
# create_makefile('pdf417') installed a top-level pdf417.so, which made the
# gem unloadable on a clean Linux install (LoadError at boot).
create_makefile('pdf417/pdf417')
