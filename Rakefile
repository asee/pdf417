require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "pdf417"
    gem.summary = %Q{A Ruby wrapper for the PDF417 barcode library}
    gem.description = %Q{Generate a series of codewords or a binary blob for PDF417 barcodes}
    gem.email = "j.prior@asee.org"
    gem.homepage = "http://github.com/asee/pdf417"
    gem.authors = ["jamesprior"]
    gem.extensions << 'ext/pdf417/extconf.rb'
    gem.require_paths << 'ext'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pdf417 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include("*.rdoc")
  rdoc.rdoc_files.include("ext/pdf417/*.c")
end

desc 'rebuilds the pdf417 library'
task :build_extension do
  pwd = `pwd`
  system "cd ext/pdf417 && make clean"
  system "cd ext/pdf417 && ruby extconf.rb && make"
end
