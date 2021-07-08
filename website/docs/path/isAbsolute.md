---
title: path.isAbsolute
---

Determines if a given file system path is absolute.

```lua
result = path.isAbsolute('value')
```

### Parameters

`value` is the path to check.

### Return Value

`true` if the path is absolute, `false` otherwise. The tests include checking for a leading forward or backward slash, a dollar sign (indicating a environment variable), or a DOS drive letter.

### Availability

Premake 6.0 or later (available in 4.0 or later as `path.isabsolute()`).

### See Also

* [path.getAbsolute](getAbsolute.md)
