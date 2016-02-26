require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc 'rebuilds the pdf417 library'
task :build_extension do
  pwd = `pwd`
  system "cd ext/pdf417 && make clean"
  system "cd ext/pdf417 && ruby extconf.rb && make"
end


task :test => [:build_extension]