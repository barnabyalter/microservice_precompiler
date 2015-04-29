require 'rubygems'
require 'test_helper'

class BuilderTest < Test::Unit::TestCase

  def setup
    @project_root = File.dirname(__FILE__) + '/../dummy'
    @precompiler = MicroservicePrecompiler::Builder.new(@project_root)
    @sprocket_assets = [:javascripts, :stylesheets]
  end

  def test_initialize
    precompiler = nil
    assert_nothing_raised(){ precompiler = MicroservicePrecompiler::Builder.new(@project_root) }
    assert_not_nil(precompiler.project_root)
    assert_equal(precompiler.project_root, @project_root)
    assert_not_nil(precompiler.build_path)
    assert_equal(precompiler.build_path, @project_root + "/dist")
    assert_not_nil(precompiler.mustaches_filename)
    assert_equal(precompiler.mustaches_filename, "mustaches.yml.tml")
  end

  def test_cleanup
    cleanup = nil
    assert_nothing_raised(){ cleanup = @precompiler.cleanup }
    assert((File.directory? @precompiler.build_path), "The build path does not exist")
    #Check that all assets folders exist
    assert((File.exists? "#{@project_root}/dist/stylesheets"), "No stylesheets folder found")
    assert((File.exists? "#{@project_root}/dist/javascripts"), "No javascripts folder found")
    assert((File.exists? "#{@project_root}/dist/templates"), "No templates folder found")
  end

  def test_compass_build
    compass = nil
    assert_nothing_raised(){ compass = @precompiler.compass_build }
    assert((File.exists? "#{@project_root}/stylesheets"), "No stylesheets folder found, compass build failed")
  end

  def test_sprockets_build
    sprockets = nil
    assert_nothing_raised(){ sprockets = @precompiler.sprockets_build }
    assert((File.exists? "#{@project_root}/dist"), "The build path does not exist")
    assert((File.exists? "#{@project_root}/dist/stylesheets"), "No stylesheets folder found, sprockets build failed")
    #Check that the files in stylesheets are minimized
    assert((File.size("#{@project_root}/stylesheets/screen.css") > File.size("#{@project_root}/dist/stylesheets/screen.css")), "Stylesheets were not minimized.")
    assert((File.exists? "#{@project_root}/dist/javascripts"), "No javascripts folder found, sprockets build failed")
    #Check that the files in javascripts are minimized
    #TODO
  end

  def test_mustache_build
    mustache = nil
    assert_nothing_raised(){ mustache = @precompiler.mustache_build }
    assert((File.exists? "#{@project_root}/dist"), "The build path does not exist")
    assert((File.exists? "#{@project_root}/dist/templates"), "No templates folder found")
    assert((File.exists? "#{@project_root}/dist/templates/Sample.html"), "File not found.")
  end


end
