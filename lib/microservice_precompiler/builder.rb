module MicroservicePrecompiler
  class Builder
    attr_accessor :project_root, :build_path, :mustaches_config
    
    def initialize project_root = ".", build_path = "dist", mustaches_config = "mustaches.yml.tml"
      @project_root = project_root
      @build_path = File.join(@project_root, build_path)
      @mustaches_config = mustaches_config
    end

    def compile downcase = true
      self.cleanup
      self.compass_build
      self.sprockets_build
      self.mustache_build downcase
    end
  
    def cleanup sprocket_assets = [:javascripts, :stylesheets]
      FileUtils.rm_r @build_path if File.exists?(@build_path)
      Compass::Exec::SubCommandUI.new(["clean", @project_root]).run!
      # Don't initialize Compass assets, the config will take care of it
      sprocket_assets.each do |asset|
        FileUtils.mkdir_p File.join(@build_path, asset.to_s)
      end
      mustaches_config_file = File.join(@project_root, @mustaches_config)
      if File.exists?(mustaches_config_file)
        mustaches_config = YAML.load_file(mustaches_config_file)
        if mustaches_config
          mustaches_config.each_key do |dir|
            FileUtils.mkdir_p File.join(@build_path, dir.to_s)
          end
        end
      end
    end
  
    def compass_build
      Compass::Exec::SubCommandUI.new(["compile", @project_root, "-s", "compact"]).run!
    end
    alias_method :compass, :compass_build
    
    def sprockets_build sprocket_assets = [:javascripts, :stylesheets]
      sprocket_assets.each do |asset_type|
        load_path = File.join(@project_root, asset_type.to_s)
        next unless File.exists?(load_path)
        sprockets_env.append_path load_path
        Dir.new(load_path).each do |filename|
          file = File.join(load_path, filename)
          if File.exists?(file) and File.file?(file)
            asset = sprockets_env[filename]
            attributes = sprockets_env.attributes_for(asset.pathname)
            name, format = attributes.logical_path, attributes.format_extension
            asset = minify(asset, format)
            build_file = File.join(@build_path, asset_type.to_s, name)
            File.open(build_file, 'w') do |f|
              f.write(asset)
            end
          end
        end
      end
    end
    alias_method :sprockets, :sprockets_build
    
    def mustache_build downcase = true
      mustaches_config_file = "#{@project_root}/#{@mustaches_config}"
      if File.exists?(mustaches_config_file)
        # Load up file as a hash
        mustaches_config = YAML.load_file(mustaches_config_file)
        if mustaches_config.is_a? Hash
          mustache_build_folder_structure(mustaches_config, downcase)
        end
      end
    end
    alias_method :mustache, :mustache_build
        
    private
    def mustache_build_folder_structure mustaches_config, downcase, parent = ""
      # Loop through each directory matched to a set of mustache classes/subclasses
      mustaches_config.each do |dir, mustaches|
        dir = (parent.eql? "") ? "#{dir}" : "#{parent}/#{camelcase_to_underscore(dir)}"
       
        mustaches.each do |mustache|
          # Get the name of the template class
          template_class = (mustache.is_a? Hash) ? mustache.keys.first : mustache
          # Get the name of the template file
          template_file = camelcase_to_underscore(template_class)
          # If the template class is an array of other classes, then these inherit from it
          if mustache[template_class].is_a? Array
            mustache[template_class].each do |logic_file|
              if logic_file.is_a? Hash
                # If the logic file is an array, then treat it like a folder and recurs
                mustache_build_folder_structure(logic_file, downcase, dir)
              else
                mustache_template_build(dir, downcase, template_file, logic_file)
              end
            end
          else
            mustache_template_build(dir, downcase, template_file, template_class)
          end
        end
      end  
    end
      
    def mustache_template_build dir, downcase, template_file, logic_file
      logic_class_name = underscore_to_camelcase(logic_file)
      logic_file = camelcase_to_underscore(logic_file)
      output_file = (downcase.eql? true) ? logic_file : logic_class_name
      # Require logic file, used to generate content from template
      require File.join(@project_root, dir, logic_file)
      # Create relevant directory path
      FileUtils.mkdir_p File.join(@build_path, dir.to_s)
      # Instantiate class from required file
      mustache = Kernel.const_get(logic_class_name).new
      # Set the template file
      mustache.template_file = File.join(@project_root, dir, template_file) + ".html.mustache"
      # Get the name of the file we will write to after it's template is processed
      build_file = File.join(@build_path, dir, "#{output_file}.html")
      File.open(build_file, 'w') do |f|
        f.write(mustache.render)
      end
    end 
    
    def camelcase_to_underscore camelcase_string
      camelcase_string.gsub(/(.)([A-Z])/,'\1_\2').downcase  
    end
    
    def underscore_to_camelcase underscore_string
      underscore_string = underscore_string.gsub(/(_)/,' ').split(' ').each { |word| word.capitalize! }.join("") unless underscore_string.match(/_/).nil?
      underscore_string = underscore_string if underscore_string.match(/_/).nil?
      return underscore_string
    end
    
    def sprockets_env
      # Initialize sprockets environment
      @sprockets_env ||= Sprockets::Environment.new(@project_root) { |env| env.logger = Logger.new(STDOUT) }
    end
    
    def minify(asset, format)
      asset = asset.to_s
      # Minify JS
      return Uglifier.compile(asset) if format.eql?(".js")
      # Minify CSS
      return YUI::CssCompressor.new.compress(asset) if format.eql?(".css")
    end
  
  end
end
