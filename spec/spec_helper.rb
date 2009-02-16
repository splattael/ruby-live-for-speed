begin
  require 'rubygems'
  gem 'rspec', '> 0.9.0'
rescue LoadError
end

require 'spec'
require 'stringio'
require 'bindata'

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'lfs'
