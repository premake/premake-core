The **iif** function implements an immediate "if" clause, returning one of two possible values.

```lua
result = iif(condition, trueval, falseval)
```

## Parameters ##

*condition* is the logical condition to test. *trueval* is the value to return if the condition evaluates to true, *falseval* if the condition evaluates false.

## Return Value ##

*trueval* is the condition evaluates true, *falseval* otherwise.

## Examples ##

```lua
result = iif(os.is("windows"), "is windows", "is not windows")
```

Note that all expressions are evaluated before the condition is checked; the following expression can not be implemented with an immediate if because it may try to concatenate a string value.

```lua
result = iif(x ~= nil, "x is " .. x, "x is nil")
```
