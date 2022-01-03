require "./spec_helper"

describe URITemplate::Template do
  describe "parse" do
    it "parses an empty string" do
      URITemplate::Template.parse("").should eq ([] of String | URIVariable)
    end
    it "parses an literal string" do
      URITemplate::Template.parse("abc").should eq ["abc"]
    end
    it "parses a single expression" do
      abcvar = URIVariable.new("abc")
      URITemplate::Template.parse("{abc}").should eq [abcvar]
    end
    it "parses a lit+expr" do
      ex1 = URIVariable.new("dog")
      URITemplate::Template.parse("cat{dog}").should eq ["cat", ex1]
    end
    it "parses a expr+lit" do
      ex1 = URIVariable.new("#dog")
      URITemplate::Template.parse("{#dog}cat").should eq [ex1, "cat"]
    end
    it "fails to parse duplicate open-bracket" do
      expect_raises(InvalidError, /duplicate open-bracket/) {
        URITemplate::Template.parse("abcd{{dog}}1234")
      }
    end
    it "fails to parse when open-bracket is not terminated" do
      expect_raises(InvalidError, /missing closing-bracket/) {
        URITemplate::Template.parse("abcd{dog")
      }
    end
    it "fails to parse when close-bracket is found before open-bracket" do
      expect_raises(InvalidError, /without matching open-bracket/) {
        URITemplate::Template.parse("abcd}dog")
      }
    end
  end
end
