---
title: export.append
---

Appends a formatted string to the current exported output, with no identation or end-of-line sequences.

```lua
export.append('format', ...)
```

### Parameters

`format` is a Lua `print()` style formatting string, followed the arguments for any formatting tokens used.

### Return Value

None.

### Availability

Premake 6.0 or later.

### See Also

- [`export.appendLine`](export_appendLine.md)

### Examples

```lua
export.append('Condition="$(Configuration)"=="%s"', cfg.vs_build)
```
