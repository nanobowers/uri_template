require "./spec_helper"
require "./rfc_helper"

include URITemplate

class RFCTemplateExamples
  @@level4_value_modifier_examples : ExpMap = {
    "{var:3}"  => {expansion: VAR, expected: "val"},
    "{var:30}" => {expansion: VAR, expected: "value"},
    "{list}"   => {expansion: LIST_EX.as(VariableValueHash), expected: "red,green,blue"},
    "{list*}"  => {expansion: LIST_EX, expected: "red,green,blue"},
    "{keys}"   => {expansion: KEYS, expected: "semi,%3B,dot,.,comma,%2C"},
    "{keys*}"  => {expansion: KEYS, expected: "semi=%3B,dot=.,comma=%2C"},
  }
  @@level4_reserved_examples = {
    "{+path:6}/here" => {expansion: PATH, expected: "/foo/b/here"},
    "{+list}"        => {expansion: LIST_EX, expected: "red,green,blue"},
    "{+list*}"       => {expansion: LIST_EX, expected: "red,green,blue"},
    "{+keys}"        => {expansion: KEYS, expected: "semi,;,dot,.,comma,,"},
    "{+keys*}"       => {expansion: KEYS, expected: "semi=;,dot=.,comma=,"},
  }
  @@level4_fragment_examples = {
    "{#path:6}/here" => {expansion: PATH, expected: "#/foo/b/here"},
    "{#list}"        => {expansion: LIST_EX, expected: "#red,green,blue"},
    "{#list*}"       => {expansion: LIST_EX, expected: "#red,green,blue"},
    "{#keys}"        => {expansion: KEYS, expected: "#semi,;,dot,.,comma,,"},
    "{#keys*}"       => {expansion: KEYS, expected: "#semi=;,dot=.,comma=,"},
  }
  @@level4_label_examples = {
    "X{.var:3}" => {expansion: VAR, expected: "X.val"},
    "X{.list}"  => {expansion: LIST_EX, expected: "X.red,green,blue"},
    "X{.list*}" => {expansion: LIST_EX, expected: "X.red.green.blue"},
    "X{.keys}"  => {expansion: KEYS, expected: "X.semi,%3B,dot,.,comma,%2C"},
    "X{.keys*}" => {expansion: KEYS, expected: "X.semi=%3B.dot=..comma=%2C"},
  }

  @@level4_path_slash_examples = {
    "{/var:1,var}" => {expansion: VAR, expected: "/v/value"},
    "{/list}"      => {expansion: LIST_EX, expected: "/red,green,blue"},
    "{/list*}"     => {expansion: LIST_EX, expected: "/red/green/blue"},
    "{/list*,path:4}" => {expansion: LIST_EX.merge(PATH), expected: "/red/green/blue/%2Ffoo"},
    "{/keys}"  => {expansion: KEYS, expected: "/semi,%3B,dot,.,comma,%2C"},
    "{/keys*}" => {expansion: KEYS, expected: "/semi=%3B/dot=./comma=%2C"},
  }

  @@level4_path_semi_examples = {
    "{;hello:5}" => {expansion: HELLO, expected: ";hello=Hello"},
    "{;list}"    => {expansion: LIST_EX, expected: ";list=red,green,blue"},
    "{;list*}"   => {expansion: LIST_EX, expected: ";list=red;list=green;list=blue"},
    "{;keys}"    => {expansion: KEYS, expected: ";keys=semi,%3B,dot,.,comma,%2C"},
    "{;keys*}"   => {expansion: KEYS, expected: ";semi=%3B;dot=.;comma=%2C"},
  }
  @@level4_form_amp_examples = {
    "{?var:3}" => {expansion: VAR, expected: "?var=val"},
    "{?list}"  => {expansion: LIST_EX, expected: "?list=red,green,blue"},
    "{?list*}" => {expansion: LIST_EX, expected: "?list=red&list=green&list=blue"},
    "{?keys}"  => {expansion: KEYS, expected: "?keys=semi,%3B,dot,.,comma,%2C"},
    "{?keys*}" => {expansion: KEYS, expected: "?semi=%3B&dot=.&comma=%2C"},
  }
  @@level4_form_query_examples = {
    "{&var:3}" => {expansion: VAR, expected: "&var=val"},
    "{&list}"  => {expansion: LIST_EX, expected: "&list=red,green,blue"},
    "{&list*}" => {expansion: LIST_EX, expected: "&list=red&list=green&list=blue"},
    "{&keys}"  => {expansion: KEYS, expected: "&keys=semi,%3B,dot,.,comma,%2C"},
    "{&keys*}" => {expansion: KEYS, expected: "&semi=%3B&dot=.&comma=%2C"},
  }

  class_getter :level4_value_modifier_examples
  class_getter :level4_reserved_examples
  class_getter :level4_fragment_examples
  class_getter :level4_label_examples
  class_getter :level4_path_slash_examples
  class_getter :level4_path_semi_examples
  class_getter :level4_form_amp_examples
  class_getter :level4_form_query_examples
end

describe "level4" do
  it "parses level4 value modifier examples" do
    examples = RFCTemplateExamples.level4_value_modifier_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 reserved examples" do
    examples = RFCTemplateExamples.level4_reserved_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 fragment examples" do
    examples = RFCTemplateExamples.level4_fragment_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 label examples" do
    examples = RFCTemplateExamples.level4_label_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 path slash examples" do
    examples = RFCTemplateExamples.level4_path_slash_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 path semi examples" do
    examples = RFCTemplateExamples.level4_path_semi_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 form ampersand examples" do
    examples = RFCTemplateExamples.level4_form_amp_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
  it "parses level4 form query examples" do
    examples = RFCTemplateExamples.level4_form_query_examples
    examples.each do |uri, tup|
      t = URITemplate.new(uri)
      t.expand(tup[:expansion]).should eq tup[:expected]
    end
  end
end
