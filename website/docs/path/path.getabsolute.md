Converts a relative path to an absolute path.

```lua
p = path.getabsolute("path", "relativeTo")
```

### Parameters ###

`path` is the relative path to be converted. It does not need to actually exist on the file system.

If provided, `relativeTo` specifies an absolute path from which `path` is considered relative. If not specified, the current working directory will be used.

### Return Value ###

A new absolute path, calculated from the current working directory, or the `relativeTo` parameter if provided.

### Availability ###

Premake 4.0 or later. The `relativeTo` parameter is available in Premake 5.0 or later.

### See Also ###

* [path.isabsolute](path.isabsolute.md)
