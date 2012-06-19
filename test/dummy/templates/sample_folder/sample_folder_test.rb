require File.join(File.dirname(__FILE__), '../sample')
class SampleFolderTest < Sample
  attr_reader :header
  def initialize
    @header = "HEADER SAMPLE FOLDER"
  end
end