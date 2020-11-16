require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

Dir["#{File.expand_path('..', __FILE__)}/tasks/**/*.rake"].each { |f| load f }

desc 'pry console for gem'
task :c do
  require 'pry'
  require 'lurker'
  require 'lurker/cli'
  ARGV.clear
  Pry.start
end

ENV['COVERALLS_NOISY'] = '1'
Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format progress"
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "features --format progress"
end

task :default => ["clobber:coverage", :spec, :regenerate, :cucumber, 'coveralls:push']

desc 'releases gem & updates docs'
task :publish do
  require 'lurker'
  version = Lurker::VERSION

  Bundler.with_unbundled_env do
    system "git tag v#{version}"
    system "relish versions:add razum2um/lurker:#{version}"
    system "relish push razum2um/lurker:#{version}"
    system "gem build lurker.gemspec"
    system "git push --tags"
    system "gem push lurker-#{version}.gem"
  end
end
