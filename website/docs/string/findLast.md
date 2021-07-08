---
title: string.findLast
---

Find the last instance of a pattern within a string.

```lua
match = string.findLast('string', 'pattern', plain)
```

### Parameters

`string` is the string to be searched.

`pattern` is the pattern to search for; it may use [Lua patterns](https://www.lua.org/manual/5.3/manual.html#6.4.1).

If `plain` is true, uses a simple string compare with no pattern matching will be performed (faster).

### Return Value

The matching pattern, if found, or `nil` if there were no matches.

### Availability

Premake 6.0 or later (available in 4.0 or later as `string.findlast()`).
