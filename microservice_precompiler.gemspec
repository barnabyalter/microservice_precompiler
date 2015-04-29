# -*- encoding: utf-8 -*-
require File.expand_path('../lib/microservice_precompiler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["barnabyalter"]
  gem.email         = ["barnaby.alter@nyu.edu"]
  gem.description   = %q{The microservice precompiler uses a handful of technologies to compile Javascripts and Stylesheets and create HTML pages from templates into a distribution folder ready for deployment. The microservices used are CoffeeScript, SASS and Mustache, compiling and minifying (where possible) into Javascript, CSS and HTML, respectively.}
  gem.summary       = %q{The microservice precompiler uses a handful of technologies to compile Javascripts and Stylesheets and create HTML pages from templates into a distribution folder ready for deployment.}
  gem.homepage      = "https://github.com/barnabyalter/microservice-precompiler"


  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "microservice_precompiler"
  gem.require_paths = ["lib"]
  gem.version       = MicroservicePrecompiler::VERSION

  gem.add_dependency "compass", "~> 1.0.0"
  gem.add_dependency "sprockets", "~> 3.0.0"
  gem.add_dependency "uglifier", "~> 2.7.1"
  gem.add_dependency "mustache", ">= 0.99.4"
  gem.add_dependency "yui-compressor", "~> 0.12.0"
  gem.add_dependency "coffee-script", "~> 2.4.0"
end
