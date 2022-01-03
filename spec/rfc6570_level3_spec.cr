require "./spec_helper"
require "./rfc_helper"

include URITemplate

class RFCTemplateExamples
  @@level3_multivar_examples : ExpMap = {
    "map?{x,y}"   => {expansion: XY.as(VariableValueHash), expected: "map?1024,768"},
    "{x,hello,y}" => {expansion: XY.merge(HELLO).as(VariableValueHash), expected: "1024,Hello%20World%21,768"},
  }
  @@level3_reserved_examples : ExpMap = {
    "{+x,hello,y}"   => {expansion: XY.merge(HELLO).as(VariableValueHash), expected: "1024,Hello%20World!,768"},
    "{+path,x}/here" => {expansion: PATH.merge(X).as(VariableValueHash), expected: "/foo/bar,1024/here"},
  }
  @@level3_fragment_examples : ExpMap = {
    "{#x,hello,y}"   => {expansion: XY.merge(HELLO).as(VariableValueHash), expected: "#1024,Hello%20World!,768"},
    "{#path,x}/here" => {expansion: PATH.merge(X).as(VariableValueHash), expected: "#/foo/bar,1024/here"},
  }
  @@level3_label_examples = {
    "X{.var}" => {expansion: VAR, expected: "X.value"},
    "X{.x,y}" => {expansion: XY, expected: "X.1024.768"},
  }
  @@level3_path_examples : ExpMap = {
    # level3_path_segment_examples
    "{/var}"        => {expansion: VAR.as(VariableValueHash), expected: "/value"},
    "{/var,x}/here" => {expansion: VAR.merge(X).as(VariableValueHash), expected: "/value/1024/here"},
    # level3_path_semi_examples
    "{;x,y}"       => {expansion: XY.as(VariableValueHash), expected: ";x=1024;y=768"},
    "{;x,y,empty}" => {expansion: XYEMPTY, expected: ";x=1024;y=768;empty"},
  }
  @@level3_form_examples : ExpMap = {
    # form amp examples
    "{?x,y}"       => {expansion: XY.as(VariableValueHash), expected: "?x=1024&y=768"},
    "{?x,y,empty}" => {expansion: XYEMPTY, expected: "?x=1024&y=768&empty="},
    # form cont examples
    "?fixed=yes{&x}" => {expansion: X.as(VariableValueHash), expected: "?fixed=yes&x=1024"},
    "{&x,y,empty}"   => {expansion: XYEMPTY, expected: "&x=1024&y=768&empty="},
  }
  class_getter :level3_reserved_examples
  class_getter :level3_multivar_examples
  class_getter :level3_fragment_examples
  class_getter :level3_path_examples
  class_getter :level3_form_examples
end

describe "level3" do
  it "parses level3 multiple variable examples" do
    examples = RFCTemplateExamples.level3_multivar_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level3 reserved examples" do
    examples = RFCTemplateExamples.level3_reserved_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level3 fragment examples" do
    examples = RFCTemplateExamples.level3_fragment_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level3 form examples" do
    examples = RFCTemplateExamples.level3_form_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level3 path examples" do
    examples = RFCTemplateExamples.level3_path_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
end
