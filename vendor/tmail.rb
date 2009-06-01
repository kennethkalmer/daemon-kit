# Prefer gems to the bundled libs.
require 'rubygems'

begin
  gem 'tmail', '~> 1.2.3'
rescue Gem::LoadError
  $:.unshift "#{File.dirname(__FILE__)}/tmail-1.2.3"
end

module TMail
end

require 'tmail'
