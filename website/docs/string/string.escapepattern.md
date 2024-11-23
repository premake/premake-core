Escapes the string for use in Lua patterns. Escapes the following characters `( ) . % + - * ? [ ] ^ $` with `%`.

```lua
escaped = string.escapepattern("s")
```

### Parameters ###

`s` is the string to escape.


### Return Value ###

Returns the input string escaped for use in Lua patterns.


### Examples ###

```lua
local match = filename:match(string.escapepattern("boost_filesystem-vc140.1.61.0.0"))
```

### Availability ###

Premake 5.0 or later.
