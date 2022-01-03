require "./uri_template/template"
require "./uri_template/variable"

# Main module for URI Templating per RFC6570 spec:
# https://datatracker.ietf.org/doc/html/rfc6570
#
# The class methods in this module are convenience methods to
# construct a URITemplate::Template object and optionally run
# a method on it.  Depending on the use model it may be more
# convenient to use URITemplate::Template directly.

module URITemplate
  # Factory method, returns a Template
  def self.new(uri : String)
    return Template.new(uri)
  end

  # Create a Template and return the variable names from it.
  def self.variables(uri : String)
    return Template.new(uri).variable_names
  end

  # Create a Template and expand it using either 
  # a Hash of arguments, or keyword-arguments or both.
  # Returns a String.
  def self.expand(uri : String, *args, **kwargs)
    return Template.new(uri).expand(*args, **kwargs)
  end

  # Create a Template and expand it partially using either 
  # a Hash of arguments, or keyword-arguments or both.
  # Returns a partially expanded Template.
  def self.expand_partial(uri : String, *args, **kwargs)
    return Template.new(uri).expand_partial(*args, **kwargs)
  end

end
