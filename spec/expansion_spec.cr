require "./spec_helper"

describe "Expansion" do
  it "expands queries" do
    v = URIVariable.new("?xyz")
    v.expand(nil).should eq "?xyz"
  end

  it "expands labels" do
    v = URIVariable.new(".xyz")
    v.expand(nil).should eq ".xyz"
    v.variable_expansion("xyz", "123", nil).should eq "123"
  end

  it "expands semis" do
    v = URIVariable.new(";xyz")
    v.expand(nil).should eq ";xyz"
    v.explode_expansion("xyz", ["bar", "bogus"]).should eq "xyz=bar;xyz=bogus"
    v.no_explode_expansion("xyz", ["bar", "bogus"]).should eq "xyz=bar,bogus"
  end

  it "expands slash explode" do
    v = URIVariable.new("/xyz*")
    empty_array = [] of ScalarVariableValue?
    empty_hash = {} of String => String
    v.explode_expansion("xyz", empty_array).should eq ""
    v.explode_expansion("xyz", [nil]).should eq ""
    v.explode_expansion("xyz", [nil, nil]).should eq ""
    v.explode_expansion("xyz", empty_hash).should eq ""
    v.explode_expansion("xyz", ["one"]).should eq "one"
    v.explode_expansion("xyz", ["one", "two"]).should eq "one/two"
    v.explode_expansion("xyz", ["one", nil, "two"]).should eq "one/two"
    v.explode_expansion("xyz", [""]).should eq ""
    v.explode_expansion("xyz", ["", ""]).should eq "/" # ???
    v.explode_expansion("xyz", empty_hash).should eq ""
    v.explode_expansion("xyz", {"one" => ""}).should eq "one="
    v.explode_expansion("xyz", {"one" => "", "two" => ""}).should eq "one=/two="
    v.explode_expansion("xyz", {"one" => nil}).should eq ""
    v.explode_expansion("xyz", {"one" => nil, "two" => "two"}).should eq "two=two"
    v.explode_expansion("xyz", {"one" => nil, "two" => nil}).should eq ""
  end

  it "expands via example 1" do
    v = URIVariable.new("/var")
    expansion = v.expand({"var" => "value"})
    expansion.should eq "/value"
  end

  it "expands via example 2" do
    v = URIVariable.new("?var,hello,x,y")
    expansion = v.expand({"var" => "value", "hello" => "Hello World!", "x" => "1024", "y" => "768"})
    expansion.should eq "?var=value&hello=Hello%20World%21&x=1024&y=768"
  end
end
