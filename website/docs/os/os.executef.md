Execute a system command, just like `os.execute()`, but accepting a format string and values as arguments.

```lua
os.executef("format", ...)
```

### Parameters ###

`format` is a printf-style formatting string (see Lua's [string.format()](http://stackoverflow.com/questions/1811884/lua-string-format-options) for examples), followed by a corresponding list of values for token substitution.


### Return Value ###

The return value of the executed command.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [os.outputof](os.outputof.md)
