(declarator) @function.builtin

(identifier) @variable
(name) @variable
(member) @variable.member
(comment) @comment

(operation) @operator

(return
  ["return"] @keyword.return)

(call_parameters
  (name) @variable.parameter)

(function_call
  (name) @function.call)

(bare_function_call
  ["print" "println"] @function)

(bare_function_call
  (quoted) @string)

(type_annotation
  (type) @type)

(type_modifier) @keyword.modifier

(function_signature
  ["fn"] @keyword)

(function_signature
  signature_name: (name) @function)

(type_descriptor
  ["<" ">"] @punctuation.bracket)

(type_descriptor
  (type) @keyword.type)

(lambda
  ["->"] @punctuation.special)

(block_lambda
  ["fn"] @keyword)

(definition_parameters
  (name) @variable.parameter)

(definition_parameters
  (type_annotation
    (type) @type))

(trailing_return
  ["->"] @punctuation.special)

(import
  ["import"] @function.builtin)

(alias
  ["alias"] @function.builtin)

(builtin_modifier) @keyword.modifier

(import
  (quoted) @string.special.path)

(struct
  ["struct"] @keyword)

(struct
  ["opaque"] @keyword.modifier)

(struct
  (name) @type.definition)

(union
  ["union"] @keyword)

(enum
  ["enum"] @keyword)

(union
  (name) @type.definition)

(enum
  (name) @type.definition)

(value
  (number) @number)
(value
  (quoted) @string)

(assembly_block
  ["{" "}"] @punctuation.bracket)

(assembly_block
  ["asm"] @keyword)

(assembly_body) @string

[":"] @operator
["(" ")"] @punctuation.bracket
["{" "}"] @punctuation.bracket
["="] @operator
[";"] @punctuation
