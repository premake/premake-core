The `verbosef` performs `printf`, printing a formatted string, but only when the **verbose** flag was set (ex. in the command line).

```lua
verbosef("format", ...)
```

## Parameters ##

**format** is a formatting string containing C `printf()` style formatting codes. It is followed by a list of arguments to be substituted into the format string.

## Return Value ##

None.