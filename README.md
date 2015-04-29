# MicroservicePrecompiler

[![Build Status](https://api.travis-ci.org/barnabyalter/microservice_precompiler.png)](https://travis-ci.org/barnabyalter/microservice_precompiler)
[![Dependency Status](https://gemnasium.com/barnabyalter/microservice_precompiler.png)](https://gemnasium.com/barnabyalter/microservice_precompiler)
[![Code Climate](https://codeclimate.com/github/barnabyalter/microservice_precompiler.png)](https://codeclimate.com/github/barnabyalter/microservice_precompiler)
[![Gem Version](https://badge.fury.io/rb/microservice_precompiler.png)](http://badge.fury.io/rb/microservice_precompiler)
[![Coverage Status](https://coveralls.io/repos/barnabyalter/microservice_precompiler/badge.png?branch=master)](https://coveralls.io/r/barnabyalter/microservice_precompiler)

The microservice precompiler uses a handful of technologies to compile Javascripts and Stylesheets and create HTML pages from templates into a distribution folder ready for deployment. The so-called "microservices" used are CoffeeScript, SASS and Mustache, compiling and minifying (where possible) into Javascript, CSS and HTML, respectively.

The SASS (or SCSS) is compiled into CSS via Compass; the CoffeeScript is translated to Javascript via Sprockets; both CSS and JS have their dependency trees included in-file by Sprockets; CSS and JS are then minified and compressed via YUICompressor and Uglifier, respectively.

The gem requires that your project root be a Compass project and expects that you have a folder structure matching the following in the root of your project:

    javascripts/
    sass/
    templates/
    mustaches.yml

Where javascripts/ contains your Coffee, sass/ contains your SASS, and templates contains a folder structure matching your mustaches.yml file for building out pages from mustache templates (see below).

## Installation

To use with bundler add this to your Gemfile:

    gem 'microservice_precompiler'

Or install it yourself:

    $ gem install microservice_precompiler

## Usage

To build all assets and templates into the distribution (./dist by default) folder:

```ruby
require 'microservice_precompiler'
precompiler = MicroservicePrecompiler::Builder.new
precompiler.compile
```

Or with initialize options:

    require 'microservice_precompiler'
    precompiler = MicroservicePrecompiler::Builder.new
    precompiler.project_root = "."
    precompiler.build_path = "dist"
    precompiler.mustaches_filename = "mustaches.yml"
    precompiler.compile

This runs all the precompiling options. Each can also be invoked individually:

    # Clears the dist folder and sass cache files
    precompiler.cleanup
    # Runs the Compass build, which sends SASS to cachs
    precompiler.compass_build
    # Runs the Sprockets build which compiles CoffeeScript, minifies assets and moves to dist folder
    precompiler.sprockets_build
    # Runs the Mustache template build, which creates output files with the same syntax from the mustaches config yaml
     precompiler.mustache_build

### SASS and CoffeeScript

These two parts are pretty simple. They are contained within their relevant directories and are written in their respective technologies. Because Sprockets is used to compile them the folders may contain subfolders which are automatically included in-line if the following line is present in a top-level file (where dependencies is the name of the subfolder you wish to include):

```coffee
/*
 *=require_tree ./dependencies
 */
```

### Mustache templating

The mustache builder requires you to provide a template file and a logic file from which to build the template. You can create a complex folder structure in the templates directory as long as it's logic is matched in the mustaches.yml config file. An example of the mustaches.yml follows:

    templates:
      - Sample:
        - Sample
        - Sample1
        - SampleFolder:
          - Sample2:
            - Sample2
        - SampleFolder:
          - Sample2
        - sample_with_underscore

* The case of the files is preserved from the mustaches config yaml. However, files like the above 'sample_with_underscore' are assumed to contain a class SampleWithUnderscore since this is the standard ruby practice.
* The top level is the directory you are building from. Multiple directories will work as well.
* The top level directory contains an array of template names, each of which is a hash of logic files to use the template.
** For example, Sample and Sample1 are two logic files which implement a mustache template called Sample.
* If one of the logic files is itself a hash it is assumed to be a directory. The mustache builder will treat this the same as the top level directory, reading the array of template file hashes with their array of logic files.
** In the above example, SampleFolder is a folder which contains a mustache template called Sample2 and a logic file Sample2 which implements the template Sample2. The following SampleFolder with only Sample2 beneath is does the same thing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/barnabyalter/microservice_precompiler/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
