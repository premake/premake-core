The `printf` performs like its C counterpart, printing a formatted string.

```lua
printf("format", ...)
```

It is equivalent to this Lua code:

```lua
print(string.format(format, unpack(arg))
```

## Parameters ##

**format** is a formatting string containing C `printf()` style formatting codes. It is followed by a list of arguments to be substituted into the format string.

## Return Value ##

None.
