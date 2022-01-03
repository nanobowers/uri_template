require "uri"

module URITemplate
  alias ScalarVariableValue = (Int32 | Float64 | String)
  alias VariableValue = Array(ScalarVariableValue) |
                        Hash(String, ScalarVariableValue) |
                        ScalarVariableValue | Nil

  alias VariableValueHash = Hash(String, VariableValue)

  # Error thrown when the template is invalid
  class InvalidError < Exception
  end

  # level  |   1      2      3       3       3      3      3      2
  # .------------------------------------------------------------------.
  # |       |  NUL     +      .       /       ;      ?      &      #   |
  # |------------------------------------------------------------------|
  # | first |  ""     ""     "."     "/"     ";"    "?"    "&"    "#"  |
  # | sep   |  ","    ","    "."     "/"     ";"    "&"    "&"    ","  |
  # | named | false  false  false   false   true   true   true   false |
  # | ifemp |  ""     ""     ""      ""      ""     "="    "="    ""   |
  # | allow |   U     U+R     U       U       U      U      U     U+R  |
  # `------------------------------------------------------------------'

  abstract struct BaseExpression
    getter :named, :ifemp, :quote_reserved, :sep, :first

    def initialize
      @first = ""
      @sep = ','
      @named = false
      @ifemp = ""
      @quote_reserved = false
    end
  end

  # 3.2.2.  Simple String Expansion: {var}
  struct StringExpression < BaseExpression
    def initialize
      super
      @first, @sep = "", ','
    end
  end

  # 3.2.3.  Reserved Expansion: {+var}
  struct PlusExpression < BaseExpression
    def initialize
      super
      @first, @sep = "", ','
      @quote_reserved = true
    end
  end

  # 3.2.4.  Fragment Expansion: {#var}
  struct OctothorpeExpression < BaseExpression
    def initialize
      super
      @first, @sep = "#", ','
      @quote_reserved = true
    end
  end

  # 3.2.5.  Label Expansion with Dot-Prefix: {.var}
  struct DotExpression < BaseExpression
    def initialize
      super
      @first, @sep = ".", '.'
    end
  end

  # 3.2.6.  Path Segment Expansion: {/var}
  struct SlashExpression < BaseExpression
    def initialize
      super
      @first, @sep = "/", '/'
    end
  end

  # 3.2.7.  Path Style Parameter Expansion {;var}
  struct SemiExpression < BaseExpression
    def initialize
      super
      @first, @sep = ";", ';'
      @named = true
    end
  end

  # 3.2.8.  Form-Style Query Expansion: {?var}
  struct QuestionExpression < BaseExpression
    def initialize
      super
      @first, @sep = "?", '&'
      @named = true
      @ifemp = "="
    end
  end

  # 3.2.9.  Form-Style Query Continuation: {&var}
  struct AmpersandExpression < BaseExpression
    def initialize
      super
      @first, @sep = "&", '&'
      @named = true
      @ifemp = "="
    end
  end

  class URIVariable
    getter :variable_names
    getter :original
    getter expr : BaseExpression

    def initialize(@original : String)
      @variables = [] of NamedTuple(name: String, explode: Bool, prefix: Int32?)
      @variable_names = [] of String
      @defaults = {} of String => ScalarVariableValue
      @expr, variable_list_str = parse_expression(@original)
      parse_varlist(variable_list_str)
    end

    def to_s : String
      return @original
    end

    def ==(other : URIVariable) : Bool
      return @original == other.original
    end

    # Parse variable into operator/expression struct and
    # unsplit variable-list-string
    def parse_expression(original) : {BaseExpression, String}
      firstchar, rest = original[0], original[1..]
      case firstchar
      when '=', ',', '!', '@', '|'
        raise InvalidError.new("Unsupported reserve operator #{firstchar}")
      when '+' then {PlusExpression.new, rest}
      when '.' then {DotExpression.new, rest}
      when '/' then {SlashExpression.new, rest}
      when ';' then {SemiExpression.new, rest}
      when '&' then {AmpersandExpression.new, rest}
      when '?' then {QuestionExpression.new, rest}
      when '#' then {OctothorpeExpression.new, rest}
      else          {StringExpression.new, original}
      end
    end

    # Parse variable-list-string into variables with defaults,
    # prefix and explode
    def parse_varlist(variable_list_str)
      variable_list_str.split(",").each do |var|
        default_val = nil
        name = var.dup
        prefix : Int32? = nil
        explode : Bool = false
        if name.ends_with?("*")
          explode = true
          name = name[0...-1]
        end
        if name.includes?(":")
          name, prefix_str = name.split(":", 2)
          prefix = prefix_str.to_i { raise InvalidError.new("Invalid non-numeric prefix: #{prefix_str}") }
          if prefix < 0 || prefix > 9999
            raise InvalidError.new("Invalid prefix: #{prefix_str}, must be positive and less than 10000")
          end
        end

        raise InvalidError.new("Cannot use explode '*' and prefix ':' in #{var}") if explode && prefix
        # todo: should check properly formed %00 .. %FF strings rather than just '%'
        raise InvalidError.new("Unsupported char in #{name}") unless name.match(/^[[:alpha:][:digit:]_\.%]+$/)
        raise InvalidError.new("Invalid var-name #{name}, cannot end with a '.'") if name.ends_with?(".")

        if default_val
          @defaults[name] = default_val
        end
        @variables.push({name: name, explode: explode, prefix: prefix})
      end
      @variable_names = @variables.map { |x| x[:name] }
    end

    # single variable expansion for Scalar value
    def variable_expansion(name : String, value : ScalarVariableValue, prefix : Int32?) : String
      value = value.to_s
      return name + expr.ifemp if expr.named && value.empty?
      rstr = expr.named ? "#{name}=" : ""
      value = !!prefix ? value[0...prefix] : value
      return rstr + quote(value)
    end

    def no_explode_expansion(name : String, value : Array | Hash)
      qname = quote(name)
      return qname + expr.ifemp if expr.named && value.empty?
      rstr = expr.named ? "#{qname}=" : ""
      if value.is_a?(Array)
        rstr + value.map { |v| quote(v) }.join(",")
      elsif value.is_a?(Hash)
        # todo: only do this if `v` is defined (non-nil)
        rstr + value.map { |k, v| quote(k) + "," + quote(v) }.join(",")
      end
    end

    def explode_expansion(name : String, value : Array) : String
      if expr.named
        return value.map do |v|
          if v.nil?
            name + expr.ifemp
          else
            name + "=" + quote(v)
          end
        end.join(expr.sep)
      else
        return value.select { |v| !v.nil? }
          .map { |v| quote(v) }
          .join(expr.sep)
      end
    end

    def explode_expansion(name : String, value : Hash) : String
      if expr.named
        return value.map do |k, v|
          if v.nil?
            k + expr.ifemp
          else
            quote(k) + "=" + quote(v)
          end
        end.join(expr.sep)
      else
        return value.select { |k, v| !v.nil? }
          .map { |k, v| quote(k) + "=" + quote(v) }
          .join(expr.sep)
      end
    end

    # Return the original variable if the var_hash is nil
    def expand(var_hash : Nil) : String
      return @original
    end

    # Expand this variable
    def expand(var_hash : VariableValueHash) : String
      return_values = [] of String

      @variables.each do |vartuple|
        name = vartuple[:name]
        value = var_hash[name]? || @defaults[name]?
        next if value.nil?
        expanded = case value
                   in Nil
                     next
                   in ScalarVariableValue
                     variable_expansion(name, value, vartuple[:prefix])
                   in Array, Hash
                     raise InvalidError.new("Cannot use prefix with array/hash value") if vartuple[:prefix]
                     if value.empty?
                       nil # note, we bypass empty case (expanded=nil) later on.
                     elsif vartuple[:explode]
                       explode_expansion(name, value)
                     else
                       no_explode_expansion(name, value)
                     end
                   end

        next if expanded.nil?
        return_values.push(expanded)
      end

      return "" if return_values.empty?
      return expr.first + return_values.join(expr.sep)
    end

    private def quote(value) : String
      if expr.quote_reserved
        URI.encode(value.to_s, space_to_plus: false)
      else
        URI.encode_www_form(value.to_s, space_to_plus: false)
      end
    end
  end
end
