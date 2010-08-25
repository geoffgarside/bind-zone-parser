require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bind-zone-parser"
    gem.summary = %Q{BIND Zone file parser}
    gem.description = %Q{Helps with parsing records and data from BIND Zone files}
    gem.email = "geoff@geoffgarside.co.uk"
    gem.homepage = "http://github.com/geoffgarside/bind-zone-parser"
    gem.authors = ["Geoff Garside"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :build => ['lib/bind-zone-parser.rb']
task :test => [:check_dependencies, 'lib/bind-zone-parser.rb']
task :default => :test

file 'lib/bind-zone-parser.rb' => ['lib/bind-zone-parser.rl'] do
  sh 'ragel -R -o lib/bind-zone-parser.rb lib/bind-zone-parser.rl'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
