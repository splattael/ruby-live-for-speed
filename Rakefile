require 'rubygems'
require 'spec'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.libs = ["lib"]
  t.warning = false
  t.rcov = true
  t.rcov_opts = ["--text-report", "-x gems"]
  t.pattern = "lib/lfs.rb"
  t.spec_opts = %w(-O spec/spec.opts)
end

task :default => :spec
