require 'simplecov'
SimpleCov.start
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require File.expand_path("../../lib/microservice_precompiler.rb",  __FILE__)
