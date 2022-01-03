alias ExpMap = Hash(String, NamedTuple(expansion: VariableValueHash, expected: String))

class RFCTemplateExamples
  VAR     = {"var" => "value".as VariableValue}
  HELLO   = {"hello" => "Hello World!".as VariableValue}
  PATH    = {"path" => "/foo/bar".as VariableValue}
  X       = {"x" => "1024".as VariableValue}
  Y       = {"y" => "768".as VariableValue}
  XY      = X.merge(Y)
  EMPTY   = {"empty" => "".as VariableValue}
  RGB     = ["red", "green", "blue"] of ScalarVariableValue
  LIST_EX = {"list" => RGB.as(VariableValue) }
  KEYHASH = {"semi" => ";".as(ScalarVariableValue),
             "dot" => ".".as(ScalarVariableValue),
             "comma" => ",".as(ScalarVariableValue)}
  KEYS    = {"keys" => KEYHASH.as(VariableValue) }
  XYEMPTY = XY.merge(EMPTY)
end
