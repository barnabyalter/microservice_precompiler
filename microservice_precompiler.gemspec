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
  
  #gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_dependency "rake", "~> 10.0.2"
  gem.add_development_dependency "debugger"
  gem.add_development_dependency "travis-lint"
  gem.add_development_dependency "reek"
  gem.add_dependency "compass", "~> 0.12.1"
  gem.add_dependency "sprockets", "~> 2"#"~> 2.4.0"
  gem.add_dependency "uglifier", "~> 1"#"~> 1.2.4"
  gem.add_dependency "mustache", "~> 0.99.4"
  gem.add_dependency "yui-compressor", "~> 0.9.6"
  gem.add_dependency "coffee-script", "~> 2.2.0"
end

