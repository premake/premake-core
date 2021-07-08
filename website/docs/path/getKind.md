---
title: path.getKind
---

Determines if the given path is absolute or relative.

```lua
result = path.getKind('value')
```

### Parameters

`value` is the path to be tested.

### Return Value

A string value, one of:

- `'absolute'` if `value` is an absolute path
- `'relative'` if `value` is a relative path
- `'unknown'` if the kind could not be determined; this usually means the path starts with a variable of some type

### Availability

Premake 6.0 or later.
