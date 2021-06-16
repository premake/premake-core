# string.split

Returns an array of strings, each of which is a substring formed by splitting on the provided pattern.

```lua
parts = string.split('str', 'pattern', plain, limit)
```

## Parameters

`str` is the string to be split.

`pattern` is the separator pattern at which to split; it may use Lua's pattern matching syntax.

If `plain` is true, no pattern matching will be performed (faster); optional.

`limit` is an upper limit on the number splits to make; optional.

## Return Value

A list of substrings.

## Availability

Premake 6.0 or later (available in 4.0 or later as `string.explode`).
