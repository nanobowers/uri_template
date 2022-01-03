require "./spec_helper"
require "./rfc_helper"

include URITemplate

class RFCTemplateExamples
  @@level2_reserved_examples = {
    "{+var}"           => {expansion: VAR, expected: "value"},
    "{+hello}"         => {expansion: HELLO, expected: "Hello%20World!"},
    "{+path}/here"     => {expansion: PATH, expected: "/foo/bar/here"},
    "here?ref={+path}" => {expansion: PATH, expected: "here?ref=/foo/bar"},
  }
  @@level2_fragment_examples = {
    "X{#var}"   => {expansion: VAR, expected: "X#value"},
    "X{#hello}" => {expansion: HELLO, expected: "X#Hello%20World!"},
  }

  class_getter :level2_reserved_examples
  class_getter :level2_fragment_examples
end

describe "level2" do
  it "parses level2 reserved examples" do
    examples = RFCTemplateExamples.level2_reserved_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level2 fragment examples" do
    examples = RFCTemplateExamples.level2_fragment_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
end
