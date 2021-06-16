# premake.checkRequired

Test for the existence of one or more fields in a table.

```lua
premake = require('premake')
ok, err = premake.checkRequired(tbl, 'field1', 'field2', ...)
```

## Parameters

`tbl` is the table to tested.

`...` is the list of field(s) to be checked.

## Return Value

Returns `true` if all fields are present in the table, otherwise returns `false` and an error message.

## Availability

Premake 6.0 or later.
