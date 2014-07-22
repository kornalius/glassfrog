{
  function makeInteger(o) {
    return parseInt(o.join(""), 10);
  }
}

start
  = statements

literal
  = boolean
  / numeric
  / string

boolean_literal
  = "true" { return "~true"; }
  / "false" { return "~false"; }

numeric_literal
  = [+-]? literal:[0-9]+ { return literal; }

string_literal
  = '"' literal:.* '"' { return '"' + literal + '"'; }

unary_expr
  = operator:unary_op __ argument:unary_expr { return { type: "expr", operator: operator, argument: argument }; }

unary_op
  = $("+" !"=")
  / $("-" !"=")
  / "!"

multiplicative_expr
  = first:unary_expr __ rest:(__ multiplicative_op __ unary_expr)* { return { type: "binary-expr", left: first, right: rest }; }

multiplicative_op
  = $("*" !"=")
  / $("/" !"=")
  / $("%" !"=")

additive_expr
  = first:multiplicative_expr __ rest:(__ additive_op __ multiplicative_expr)* { return { type: "binary-expr", left: first, right: rest }; }

additive_op
  = $("+" ![+=])
  / $("-" ![-=])

relational_expr
  = first:additive_expr __ rest:(__ relational_op __ additive_expr)* { return { type: "binary-expr", left: first, right: rest }; }

relational_op
  = "<="
  / ">="
  / $("<" !"<")
  / $(">" !">")
  = "=="
  / "!="

relational_expr
  = first:additive_expr __ rest:(__ relational_op __ additive_expr)* { return { type: "binary-expr", left: first, right: rest }; }

logical_and_expr
  = first:relational_expr __ rest:(__ logical_and_op __ relational_expr)* { return { type: "binary-expr", left: first, right: rest }; }

logical_and_op
  = "&&"

logical_or_expr
  = first:logical_and_expr __ rest:(__ logical_or_op __ logical_and_expr)* { return { type: "binary-expr", left: first, right: rest }; }

logical_or_op
  = "||"

conditional_expr
  = logical_or_expr

object_ref_expr
  = "#" name:string { return { type: "call", ref: "object", name: name }; }

assignment_op
  = "="

assignment_expr
  = left:object_ref_expr __ "=" !"=" __ right:assignment_expr { return { type: "assign", operator: "=", name: name, value: value }; }
  / conditional_expr

method_ref
  = "MethodRef" __ name:string __ args:expr* { return { type: "call", name: name, args: args }; }

condition
  = "If" condition:condition_expr { return "If" + " " + condition; }

loop
  = for_loop
  / foreach_loop

for_loop
  = "For" var:"ObjectRef" from:expr* to:expr {
    if from
      return "For" + " " + var + " from " + from + " to " + to;
    else
      return "For" + " " + var + " from " + 0 + " to " + to;
    }

foreach_loop
  = "ForEach" var:"ObjectRef" expr:expr { return "ForEach" + " " + var + " in " + expr; }

object_definition
  = "Property"
  / "Method"
  / "Event"

property
  = "Property" name:"String" value:expr* {
    if value
      return name + " : " + value;
    else
      return name + " : " + "null";
    }

method
  = "Method" name:"String" code:statements { return name + " : { " + statements + "}"; }

object
  = "Object" name:"String" def:object_definition* { return name + " = " + def; }

statements
  = statement+

statement
  = object
  / object_assign
  / method_ref
  / condition
  / loop
