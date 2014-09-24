# -*- encoding : utf-8 -*-
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "im_order"
    gem.summary = %Q{immatériel.fr order web-services helper}
    gem.description = %Q{immatériel.fr order web-services helper}
    gem.email = "jboulnois@immateriel.fr"
    gem.homepage = "http://github.com/immateriel/im_order"
    gem.authors = ["julbouln"]
    gem.files = Dir.glob('lib/**/*')
  end
  Jeweler::GemcutterTasks.new

  require 'rake/testtask'
  Rake::TestTask.new(:test) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end

  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
    test.rcov_opts << '--exclude "gems/*"'
  end

  task :default => :test



rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

