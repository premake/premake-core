---
title: export.appendLine
---

Appends a formatted string to the current exported output, followed by the currently configured end-of-line sequence.

```lua
export.appendLine('format', ...)
```

### Parameters

`format` is a Lua `print()` style formatting string, followed the arguments for any formatting tokens used.

### Return Value

None.

### Availability

Premake 6.0 or later.

### See Also

- [`export.append`](export_append.md)

### Examples

```lua
export.appendLine('>%s</%s>', value, tag)
```
