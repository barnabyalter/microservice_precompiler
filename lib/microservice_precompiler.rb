require 'compass'
require 'compass/exec'
require 'sprockets'
require 'fileutils'
require 'uglifier'
require 'yui/compressor'

CLASS_PATH = File.dirname(__FILE__) + "/microservice_precompiler/"
[ 
  'version',
  'builder'
].each do |library|
  require CLASS_PATH + library
end