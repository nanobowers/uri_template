require "./variable"

module URITemplate
  class Template

    # A set of unique variable names in this template
    getter :variable_names
    
    # Gets the original URI string used to construct the Template object
    getter :uri

    @components : Array(String | URIVariable)
    @variable_names : Set(String)
    def initialize(@uri : String)
      @components = Template.parse(@uri)
      @variable_names = variables.flat_map(&.variable_names).to_set
    end

    # Retrieves the Components that are URIVariables
    def variables
      @components.select URIVariable
    end

    # The original URI String. 
    def to_s : String
      return @uri
    end

    # Check equality by comparing the URI field.
    def ==(other) : Bool
      return @uri == other.uri
    end

    # If the var_hash is nil, just return the URI.
    private def uri_expand(var_hash : Nil, replace : Bool) : String
      @uri
    end

    # Expand each component of the template.  Template components will be
    # either String or URIVariables, which may be expanded by var_hash.
    private def uri_expand(var_hash : VariableValueHash, partial_replace : Bool) : String
      return @uri if variables.empty?
      @components.map do |component|
        case component
        in String then component
        in URIVariable
          lookup = component.expand(var_hash)
          if partial_replace && lookup.empty?
            "{#{component.original}}"
          else # replace-all
            lookup
          end
        end
      end.join
    end

    # Merge a variable-hash and keyword args into a singular variable-hash
    # with the correct type.  Keyword args are merged last and have precedence.
    private def merger(var_hash : VariableValueHash, **kwargs) : VariableValueHash
      vars = {} of String => VariableValue
      {var_hash, kwargs}.each do |vh|
        vh.each do |k, v|
          # Is there a better way to coerce union types with 'as' ?
          case v
          in ScalarVariableValue?
            vars[k.to_s] = v.as(VariableValue)
          in Array
            vars[k.to_s] = v.map &.as(ScalarVariableValue)
          in Hash
            vars[k.to_s] = v.map { |i, j| {i, j.as(ScalarVariableValue)} }.to_h
          end
        end
      end
      return vars
    end

    # Expand the URI with the +var_hash+, keyword arguments a mix of the two.
    # Complete expansions return a String.
    def expand(var_hash : VariableValueHash? = nil, **kwargs) : String
      empty_hash = {} of String => VariableValue
      merge_hash = merger(var_hash || empty_hash, **kwargs)
      return uri_expand(merge_hash, false)
    end

    # Partial expansions should return another Template object.
    def expand_partial(var_hash : VariableValueHash? = nil, **kwargs) : Template
      empty_hash = {} of String => VariableValue
      merge_hash = merger(var_hash || empty_hash, **kwargs)
      return Template.new(uri_expand(merge_hash, true))
    end

    # Parse the template, looking for bracketed expressions.
    # In a quick survey of other implementations, many seem to use Regex's to
    # parse the template, however it's hard to pinpoint errors in
    # the input template using Regex ("do or do not, there is no try").
    def self.parse(str : String) : Array(String | URIVariable)
      parse_list = [] of String | URIVariable
      startpos = 0
      openbrk : Int32? = nil
      str.each_char.with_index do |char, idx|
        if char == '{'
          unless openbrk.nil?
            raise InvalidError.new("Invalid or duplicate open-bracket at string position #{idx}")
          end
          openbrk = idx
          parse_list << str[startpos...idx] if idx > startpos
          startpos = idx + 1
        elsif char == '}'
          if openbrk.nil?
            raise InvalidError.new("Closing-bracket at string-position #{idx} without matching open-bracket")
          end
          openbrk = nil
          parse_list << URIVariable.new(str[startpos...idx]) if idx > startpos
          startpos = idx + 1
        end
      end
      # Handle the remaining end-of-string
      if !openbrk.nil?
        raise InvalidError.new("Template missing closing-bracket")
      end
      parse_list << str[startpos...str.size] if str.size > startpos
      return parse_list
    end

  end
end
