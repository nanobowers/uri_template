require "./spec_helper"

describe URITemplate do

  describe "Top Level API" do
    it "expands" do
      uri = "https://api.github.com{/endpoint}"
      URITemplate.expand(uri, {"endpoint" => "users"}).should eq "https://api.github.com/users"
    end

    it "does a partial expansion 1" do
      uri = "https://api.github.com{/endpoint}"
      part = URITemplate.expand_partial(uri)
      part.should eq URITemplate.new(uri)
    end

    it "does a partial expansion 2" do
      uri = "https://api.github.com{/endpoint}/nanobowers{/other}"
      part = URITemplate.expand_partial(uri, endpoint: "users")
      part.should eq URITemplate.new("https://api.github.com/users/nanobowers{/other}")
      part = URITemplate.expand_partial(uri, other: "annie_dog")
      part.should eq URITemplate.new("https://api.github.com{/endpoint}/nanobowers/annie_dog")
    end

    it "reports variables" do
      uri = "https://api.github.com{/endpoint}"
      URITemplate.variables(uri).should eq URITemplate.new(uri).variable_names
    end
  end

  # This test ensures that if there are no variables present, the
  # template evaluates to itself.
  it "handles no variables in the uri" do
    uri = "https://api.github.com/users"
    t = URITemplate.new(uri)
    t.expand.should eq uri
    t.expand(users: "foo").should eq uri
  end

  # This test ensures that all variables are parsed.
  it "parses all variables" do
    uris = ["https://api.github.com",
            "https://api.github.com/users{/user}",
            "https://api.github.com/repos{/user}{/repo}",
            "https://api.github.com/repos{/user}{/repo}/issues{/issue}"]
    uris.each_with_index do |uri, idx|
      t = URITemplate.new(uri)
      t.variables.size.should eq idx
    end
  end

  # This test ensures that expansion works as expected.
  it "expands a template" do
    t = URITemplate.new("https://api.github.com/users{/user}")
    expanded = "https://api.github.com/users/nanobowers"
    t.expand(user: "nanobowers").should eq expanded
    t.variables[0].expand({"user" => nil}).should eq ""
  end

  it "expands another template" do
    t = URITemplate.new("https://github.com{/user}{/repo}")
    expanded = "https://github.com/nanobowers/cronic"
    t.expand({"repo" => "cronic"}, user: "nanobowers").should eq expanded
  end

  it "can convert the template's variable to a string" do
    uri = "https://api.github.com{/endpoint}"
    t = URITemplate.new(uri)
    t.to_s.should eq uri
    t.variables[0].to_s.should eq "/endpoint"
  end

  it "doesnt mutate the argument hash" do
    args = {} of String => String
    empty_hash = {} of String => String
    t = URITemplate.new("")
    t.expand(args, key: 1)
    args.should eq empty_hash
  end

  describe "Native type support" do
    it "expands native Crystal types" do
      context : Hash(String, Int32 | Float64 | Array(Int32)) = {"zero" => 0, "one" => 1, "digits" => 10.times.to_a, "a_float" => 3.1415}
      URITemplate.expand("{zero}", context).should eq "0"
      URITemplate.expand("{one}", context).should eq "1"
      URITemplate.expand("{digits}", context).should eq "0,1,2,3,4,5,6,7,8,9"
      URITemplate.expand("{?digits,one}", context).should eq "?digits=0,1,2,3,4,5,6,7,8,9&one=1"
      URITemplate.expand("{/digits}", context).should eq "/0,1,2,3,4,5,6,7,8,9"
      URITemplate.expand("{/digits*}", context).should eq "/0/1/2/3/4/5/6/7/8/9"
      URITemplate.expand("{/zero}", context).should eq "/0"
      URITemplate.expand("{/zero,a_float}", context).should eq "/0/3.1415"
    end
  end
  
end
