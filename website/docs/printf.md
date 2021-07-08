Print a formatted string to the console, like the C `printf` function. Wraps Lua's built-in `string.format()` and `print()`.

```lua
printf('format', ...)
```

### Parameters

`format` is the formatting string.

`...` is the list of values to satisfy any formatting tokens contained in the format string.

### Return Value

None.

### Availability

Premake 5.0 or later.

### Examples

```lua
local value = 42
printf('The answer is %d', value)
```
