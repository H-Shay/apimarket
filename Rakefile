require "rspec/core/rake_task"

task :default => :spec
RSpec::Core::RakeTask.new(:spec) do |s|
  s.pattern = "apimarket_spec.rb"
  s.rspec_opts = ["-cfs"]
end
