# string.findLast

Finds the last instance of a pattern within a string.

```lua
match = string.findLast('str', 'pattern', plain)
```

## Parameters

`str` is the string to be searched.

`pattern` is the pattern to search for; it may use Lua's pattern matching syntax.

If `plain` is true, no pattern matching will be performed (faster).

## Return Value

The matching pattern, if found, or `nil` if there were no matches.

## Availability

Premake 6.0 or later (available in 4.0 or later as `string.findlast`).
