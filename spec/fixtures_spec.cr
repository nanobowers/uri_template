require "json"
require "./spec_helper"

def fixture_file_path(filename)
  absolute_dir = Path.new(File.dirname(__FILE__)).expand
  return File.join(absolute_dir, "uritemplate-test", filename + ".json")
end

# Try to load the .json uritemplate-test examples
# If they cannot be found, then create some dummy pending
# tests so that the user is notified but it is not an outright
# test failure.
def load_examples(filename, &block)
  path = fixture_file_path(filename)
  if File.readable?(path)
    json = File.open(path) do |file|
      JSON.parse(file)
    end
    yield json
  else
    describe "fixture" do
      pending "missing #{path}"
    end
  end
end

# Convert Hash(String, JSON::Any) to
#   Hash(String, VariableValue)
def get_variables(jspecdata) : Hash(String, VariableValue)
  vars = {} of String => VariableValue
  jspecdata["variables"].as_h.each do |k, v|
    if v.as_a?
      vars[k] = v.as_a.map { |x| x.as_s.as ScalarVariableValue }
    elsif v.as_s?
      vars[k] = v.as_s.as(ScalarVariableValue)
    elsif v.as_h?
      newhash = {} of String => ScalarVariableValue
      v.as_h.each do |k2, v2|
        newhash[k2] = v2.as_s.as(ScalarVariableValue)
      end
      vars[k] = newhash
    elsif v.nil?
      vars[k] = nil.as(ScalarVariableValue)
    elsif v.as_f?
      vars[k] = v.as_f.as(ScalarVariableValue)
    elsif v.as_i?
      vars[k] = v.as_i.as(ScalarVariableValue)
    end
  end
  return vars
end

# Wrapper method for creating and testing.
# The downside of this approach is that spec line-numbers
# are the same for every test so they are hard to isolate.
def json_spec_test(jsonex, specname)
  jspecdata = jsonex[specname]
  testcases = jspecdata["testcases"].as_a
  variables = get_variables(jspecdata)
  describe specname do
    testcases.each do |tc|
      jtemplate, ref = tc.as_a
      template = jtemplate.as_s
      it "validates \"#{template}\"" do
        if ref.as_a?
          tmpl = URITemplate.new(template)
          output = tmpl.expand(variables)
          ref.as_a.should contain output
        elsif ref.as_bool? == false
          expect_raises(InvalidError) {
            tmpl = URITemplate.new(template)
            tmpl.expand(variables)
          }
        else
          tmpl = URITemplate.new(template)
          output = tmpl.expand(variables)
          output.should eq ref
        end
      end
    end
  end
end

# SPEC EXAMPLES BY LEVEL
load_examples("spec-examples") do |specex|
  json_spec_test(specex, "Level 1 Examples")
  json_spec_test(specex, "Level 2 Examples")
  json_spec_test(specex, "Level 3 Examples")
  json_spec_test(specex, "Level 4 Examples")
end

# SPEC EXAMPLES BY RFC SECTION
load_examples("spec-examples-by-section") do |jsonex|
  json_spec_test(jsonex, "3.2.1 Variable Expansion")
  json_spec_test(jsonex, "3.2.2 Simple String Expansion")
  json_spec_test(jsonex, "3.2.3 Reserved Expansion")
  json_spec_test(jsonex, "3.2.4 Fragment Expansion")
  json_spec_test(jsonex, "3.2.5 Label Expansion with Dot-Prefix")
  json_spec_test(jsonex, "3.2.6 Path Segment Expansion")
  json_spec_test(jsonex, "3.2.7 Path-Style Parameter Expansion")
  json_spec_test(jsonex, "3.2.8 Form-Style Query Expansion")
  json_spec_test(jsonex, "3.2.9 Form-Style Query Continuation")
end

# MORE EXAMPLES
load_examples("extended-tests") do |jsonex3|
  json_spec_test(jsonex3, "Additional Examples 1")
  json_spec_test(jsonex3, "Additional Examples 2")
  json_spec_test(jsonex3, "Additional Examples 3: Empty Variables")
  json_spec_test(jsonex3, "Additional Examples 4: Numeric Keys")
end

# These are expected to fail (URITemplate::InvalidError)
load_examples("negative-tests") do |jsonex|
  json_spec_test(jsonex, "Failure Tests")
end
