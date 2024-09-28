Converts from Premake's simple wildcard syntax to a corresponding Lua pattern.

```lua
p = path.wildcards("pattern")
```

### Parameters ###

`pattern` is a file system path which may contain one more `\*` (shallow match) or `\*\*` (recursive match) sequences.


### Return Value ###

A Lua pattern string which is equivalent to the input pattern.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [os.matchdirs](os/os.matchdirs.md)
* [os.matchfiles](os/os.matchfiles.md)
