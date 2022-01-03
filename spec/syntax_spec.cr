require "./spec_helper"

describe "syntax" do
  it "should refuse variables with terminal dots" do
    # .should raise_error(pendingURITemplate::Invalid)
    expect_raises(InvalidError) { URITemplate.new("{var.}") }
    expect_raises(InvalidError) { URITemplate.new("{..var.}") }
  end
end

describe "expansion" do
  it "should refuse to expand a complex variable with length limit" do
    t = URITemplate.new("{?assoc:1}")
    expect_raises(InvalidError) {
      t.expand({"assoc" => {"foo" => "bar"}})
    }
  end

  it "should refuse to expand a array variable with length limit" do
    t = URITemplate.new("{?array:1}")
    expect_raises(InvalidError) {
      t.expand({"array" => ["a", "b"]})
    }
  end

  it "should expand assocs with dots" do
    t = URITemplate.new("{?assoc*}")
    t.expand({"assoc" => {"." => "dot"}}).should eq("?.=dot")
  end

  it "should expand assocs with minus" do
    t = URITemplate.new("{?assoc*}")
    t.expand({"assoc" => {"-" => "minus"}}).should eq("?-=minus")
  end

  # it "should expand assocs when using array expansion" do
  # t = URITemplate.new("{?assoc*}")
  # t.expand([{"."=>"dot"}]).should eq("?.=dot")
  # end

  it "should expand empty arrays" do
    emptyarray = [] of String
    t = URITemplate.new("{arr}")
    t.expand({"arr" => emptyarray}).should eq("")
  end
end
