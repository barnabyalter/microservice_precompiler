module MicroservicePrecompiler
  class Builder
    attr_accessor :project_root, :build_path, :mustaches_filename

    def initialize(project_root = ".", build_path = "dist", mustaches_filename = "mustaches.yml.tml")
      @project_root = project_root
      # Compare project and build path without trailing slash,
      # they cannot be the same else `cleanup` will wipe the current directory
      if project_root.chomp("/") == build_path.chomp("/")
        raise ArgumentError, "project_root and build_path cannot be the same"
      end
      @build_path = File.join(project_root, build_path)
      @mustaches_filename = mustaches_filename
    end

    def build_path=(build_path)
      if project_root.chomp("/") == build_path.chomp("/")
        raise ArgumentError, "project_root and build_path cannot be the same"
      end
      @build_path = build_path
    end

    # Convenience method runs all the compilation tasks in order
    def compile
      cleanup
      compass_build
      sprockets_build
      mustache_build
    end

    # Public function for running cleanup of previous build
    def cleanup(sprocket_assets = [:javascripts, :stylesheets])
      # Remove previous dist path
      FileUtils.rm_r build_path if File.exists?(build_path)
      # Clean compass project
      Compass::Exec::SubCommandUI.new(["clean", project_root]).run!
      # Don't initialize Compass assets, the config will take care of it
      sprocket_assets.each do |asset|
        FileUtils.mkdir_p File.join(build_path, asset.to_s)
      end
      if mustaches_config_file_exists?
        mustaches_yaml.each_key do |dir|
          FileUtils.mkdir_p File.join(build_path, dir.to_s)
        end
      end
    end

    # Public function for wrapping a compass compiler
    def compass_build
      Compass::Exec::SubCommandUI.new(["compile", project_root, "-s", "compact"]).run!
    end
    alias_method :compass, :compass_build

    # Public function for building sprockets assets and minifying
    def sprockets_build(sprocket_assets = [:javascripts, :stylesheets])
      sprocket_assets.each do |asset_type|
        load_path = File.join(@project_root, asset_type.to_s)
        next unless File.exists?(load_path)
        sprockets_env.append_path load_path
        Dir.new(load_path).each do |filename|
          file = File.join(load_path, filename)
          if File.file?(file)
            asset = sprockets_env[filename]
            attributes = sprockets_env.find_asset(asset.pathname)
            # logical_path is the filename
            build_file = File.join(build_path, asset_type.to_s, attributes.logical_path)
            File.open(build_file, 'w') do |f|
              extension = attributes.logical_path.split(".").last
              f.write(minify(asset, extension))
            end
          end
        end
      end
    end
    alias_method :sprockets, :sprockets_build

    # Public function for building mustache tree into html
    def mustache_build
      if mustaches_config_file_exists?
        if mustaches_yaml.is_a? Hash
          mustache_build_folder_structure(mustaches_yaml)
        end
      end
    end
    alias_method :mustache, :mustache_build

    def method_missing(method_id, *args)
      if match = matches_file_exists_check?(method_id)
        File.exists?(send(method_id.to_s.gsub(/_exists\?/,"")))
      else
        super
      end
    end

  private

    # Render mustache into html for complex directory structure
    # Loop through each directory matched to a set of mustache classes/subclasses
    def mustache_build_folder_structure(logic_file, parent = nil)
      logic_file.each do |dir, mustaches|
        dir = [parent, dir].join("/")

        mustaches.each do |mustache|
          # Get the name of the template class
          template_class = (mustache.is_a? Hash) ? mustache.keys.first : mustache
          # Get the name of the template file
          template_file = camelcase_to_underscore(template_class)
          # If the template class is an array of other classes, then these inherit from it
          if mustache[template_class].is_a? Array
            mustache[template_class].each do |logic_file|
              if logic_file.is_a? Hash
              # If the logic file is an array, then treat it like a folder and recurse
                mustache_build_folder_structure(logic_file, dir)
              else
              # If the logic file is a single file, then render the template
                mustache_template_build(dir, template_file, logic_file)
              end
            end
          else
          # Base case: If the logic file is not an array of clases, render the template
            mustache_template_build(dir, template_file, template_class)
          end
        end
      end
    end

    # Render html from a mustache template
    def mustache_template_build(dir, template_file, logic_file)
      # Get the class name from an underscore-named file
      logic_class_name = underscore_to_camelcase(logic_file)
      # Output file should match the syntax of the mustaches config
      output_file = logic_file
      # Now we can name the logic_file to underscored version
      logic_file = camelcase_to_underscore(logic_file)
      # Require logic file, used to generate content from template
      require File.join(project_root, camelcase_to_underscore(dir), logic_file)
      # Create relevant directory path
      FileUtils.mkdir_p File.join(build_path, dir.to_s)
      # Instantiate class from required file
      mustache = Kernel.const_get(logic_class_name).new
      # Set the template file
      mustache.template_file = File.join(project_root, camelcase_to_underscore(dir), template_file) + ".html.mustache"
      # Get the name of the file we will write to after it's template is processed
      build_file = File.join(build_path, dir, "#{output_file}.html")
      File.open(build_file, 'w') do |f|
        f.write(mustache.render)
      end
    end

    # Convert a camelcase string to underscores
    def camelcase_to_underscore(camelcase_string)
      return camelcase_string.gsub(/([A-Za-z0-9])([A-Z])/,'\1_\2').downcase
    end

    # Conver underscore to camelcase
    def underscore_to_camelcase(underscore_string)
      underscore_string = underscore_string.gsub(/(_)/,' ').split(' ').each { |word| word.capitalize! }.join("") unless underscore_string.match(/_/).nil?
      underscore_string = underscore_string if underscore_string.match(/_/).nil?
      return underscore_string
    end

    # Initialize sprockets environment
    def sprockets_env
      @sprockets_env ||= Sprockets::Environment.new(project_root) { |env| env.logger = Logger.new(STDOUT) }
    end

    # Minify assets in format
    def minify(asset, format)
      asset = asset.to_s
      # Minify JS
      return Uglifier.compile(asset) if format.eql?("js")
      # Minify CSS
      return YUI::CssCompressor.new.compress(asset) if format.eql?("css")
      # Return string representation if not minimizing
      return asset
    end

    # Get the mustache config file with fullpath
    def mustaches_config_file
      @mustaches_config_file ||= File.join(project_root, mustaches_filename)
    end

    # Load the mustaches yaml file into a yaml object
    def mustaches_yaml
      @mustaches_yaml ||= YAML.load_file(mustaches_config_file)
    end

    # Match arbitrary_filename_file_exists?
    def matches_file_exists_check?(method_id)
      /^(.+)_file_exists\?$/.match(method_id.to_s)
    end

  end
end
