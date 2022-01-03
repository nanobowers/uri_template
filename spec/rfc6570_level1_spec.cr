require "./spec_helper"
require "./rfc_helper"

include URITemplate

class RFCTemplateExamples
  @@level1_examples : ExpMap = {
    "{var}"   => {expansion: VAR, expected: "value"},
    "{hello}" => {expansion: HELLO, expected: "Hello%20World%21"},
  }
  class_getter :level1_examples
end

describe "level1" do
  it "parses a level1 example" do
    examples = RFCTemplateExamples.level1_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
end
