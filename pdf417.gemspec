# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdf417/version'

Gem::Specification.new do |s|
  s.name = %q{pdf417}
  s.version = PDF417::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jamesprior"]
  s.date = %q{2011-07-25}
  s.description = %q{Generate a series of codewords or a binary blob for PDF417 barcodes}
  s.email = %q{j.prior@asee.org}
  s.extensions = ["ext/pdf417/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.homepage = %q{http://github.com/asee/pdf417}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.5.3}
  s.summary = %q{A Ruby wrapper for the PDF417 barcode library}
  s.test_files = [
    "test/pdf417/lib_test.rb",
     "test/pdf417_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
  
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  
end

