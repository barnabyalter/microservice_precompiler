require File.join(File.dirname(__FILE__), 'sample')
class SampleWithUnderscore < Sample
  attr_reader :header
  def initialize
    @header = "HEADER_SAMPLE"
  end
end