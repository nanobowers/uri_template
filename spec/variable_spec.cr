require "./spec_helper"

describe URIVariable do
  describe "post-parse" do
    it "sets some internal variables" do
      v = URIVariable.new("dummy")
      v.expr.sep.should eq ','
      v.expr.quote_reserved.should eq false
      v.expr.first.should eq ""
    end

    it "sets some internal vars with a plus-operator" do
      v = URIVariable.new("+dummy")
      v.expr.sep.should eq ','
      v.expr.quote_reserved.should eq true
      v.expr.first.should eq ""
    end

    it "sets some internal vars with an octothorpe" do
      v = URIVariable.new("#dummy")
      v.expr.sep.should eq ','
      v.expr.quote_reserved.should eq true
      v.expr.first.should eq "#"
    end

    it "sets some internal vars with an question-mark" do
      v = URIVariable.new("?dummy")
      v.expr.sep.should eq '&'
      v.expr.quote_reserved.should eq false
      v.expr.first.should eq "?"
    end

    it "sets some internal vars with an ampersand" do
      v = URIVariable.new("&dummy")
      v.expr.sep.should eq '&'
      v.expr.quote_reserved.should eq false
      v.expr.first.should eq "&"
    end
  end
end
