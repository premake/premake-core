---
title: string.split
---

Splits a string on a pattern; returns an array of substrings.

```lua
substrings = string.split('string', 'pattern', plain, limit)
```

### Parameters

`string` is the string to be split.

`pattern` is the separator pattern at which to split; it may use [Lua patterns](https://www.lua.org/manual/5.3/manual.html#6.4.1).

If `plain` is true, uses a simple string compare with no pattern matching will be performed (faster). Optional, may be `nil`.

`limit` is an upper limit on the number splits to make. Optional, may be `nil`.

### Return Value

A list of substrings.

### Availability

Premake 6.0 or later (available in 4.0 or later as `string.explode()`).

### Examples

```lua
local elements = string.split('Apple, Banana, Coconut', ', ', true)
print(elements[0])  -- 'Apple'
print(elements[1])  -- 'Banana'
print(elements[2])  -- 'Coconut'
```
