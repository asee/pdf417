# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdf417/version'

Gem::Specification.new do |s|
  s.name = 'pdf417'
  s.version = PDF417::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['jamesprior']
  s.description = 'Generate a series of codewords or a binary blob for PDF417 barcodes'
  s.email = 'j.prior@asee.org'
  s.extensions = ['ext/pdf417/extconf.rb']
  s.extra_rdoc_files = [
    'LICENSE',
    'README.rdoc'
  ]
  # s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.files = `git ls-files -z`.split("\x0").grep_v(%r{^(test|spec|features)/})

  s.homepage = 'http://github.com/asee/pdf417'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = %w[lib ext]
  s.required_ruby_version = '>= 3.0'
  s.summary = 'A Ruby wrapper for the PDF417 barcode library'

  s.metadata['rubygems_mfa_required'] = 'true'
end
