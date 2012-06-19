# MicroservicePrecompiler

The microservice precompiler uses a handful of technologies to compile Javascripts and Stylesheets and create HTML pages from templates into a distribution folder ready for deployment. The microservices used are CoffeeScript, SASS and Mustache, compiling and minifying (where possible) into Javascript, CSS and HTML, respectively.

The SASS is compiled into CSS via Compass; the CoffeeScript is translated to Javascript via Sprockets; both CSS and JS have their dependency trees included in-file by Sprockets; CSS and JS are then minified and compressed via YUICompressor and Uglifier, respectively. 

The gem requires that your project root be a Compass project and expects that you have a folder structure matching the following in the root of your project:

    /javascripts/
    /sass/
    /templates/
    mustaches.yml

Where javascripts contains your Coffee, sass contains your SASS, templates contains a folder structure matching your mustaches.yml file for building out pages from mustache templates. 

## Installation

Add this line to your application's Gemfile:

    gem 'microservice_precompiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install microservice_precompiler

## Usage

To build all assets and templates into the distribution (./dist by default) folder, you can run the following from your application or rake:

    require 'microservice_precompiler'
    precompiler = MicroservicePrecompiler::Builder.new
    precompiler.compile
  
Or with initialize options (the compile boolean option is for downcase, see below):
  
    require 'microservice_precompiler'
    precompiler = MicroservicePrecompiler::Builder.new
    precompiler.project_root = "."
    precompiler.build_path = "dist"
    precompiler.mustaches_config = "mustaches.yml"
    precompiler.compile false
  
This runs all the precompiling options. Each can also be invoked individually:

    # Clears the dist folder and sass cache files
    precompiler.cleanup
    # Runs the Compass build, which sends SASS to cachs
    precompiler.compass_build
    # Runs the Sprockets build which compiles CoffeeScript, minifies assets and moves to dist folder
    precompiler.sprockets_build
  
The mustache builder takes an optional argument, downcase, which tells it whether to write the output files in lowercase with underscores (the default) or keep them as the original files:

    # Keep output files the same as input files
    precompiler.mustache_build false
    # Make all output files lowercase with underscores instead of spaces, default
    precompiler.mustache_build true

### SASS and CoffeeScript

These two parts are pretty simple. They are contained within their relevant directories and are written in their respective technologies. Because Sprockets is used to compile them the folders may contain subfolders which are automatically included in-line if the following line is present in a top-level file (where dependencies is the name of the subfolder you wish to include):

    /*
     *=require_tree ./dependencies
     */

### Mustache templating

The mustache builder requires you to provide a template file and a logic file from which to build the template. You can create a complex folder structure in the templates directory as long as it's logic is matched in the mustaches.yml config file. An example of the mustaches.yml follows:

    templates:
      - Sample:
        - Sample
        - Sample1
        - SampleFolder:
          - Sample2:
            - Sample2

* By default, camelcase in the yaml file is translated to lowercase with underscores unless specified, see initializing options above.
* The top level is the directory you are building from. Multiple directories will work as well.
* The top level directory contains an array of template names, each of which is a hash of logic files to use the template.
** For example, Sample and Sample1 are two logic files which implement a mustache template called Sample.
* If one of the logic files is itself a hash it is assumed to be a directory. The mustache builder will treat this the same as the top level directory, reading the array of template file hashes with their array of logic files.
** In the above example, SampleFolder is a folder called sample_folder which contains a mustache template called Sample2 and a logic file Sample2 which implements the template Sample2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
