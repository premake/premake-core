# path.getAbsolute

Converts a relative path an absolute path.

```lua
path = require('path')
result = path.getAbsolute('relativePath', 'relativeTo')
```

## Parameters

`relativePath` is the relative path to be converted. It does not need to actually exist on the file system.

If provided, `relativeTo` specifies an absolute path from which `path` is considered relative. If not specified, the current working directory will be used.

## Return Value

A new absolute path, calculated from the current working directory, or the `relativeTo` parameter if provided.

## Availability

Premake 6.0 or later (available in 4.0 or later as `path.getabsolute`). The `relativeTo` parameter is available in Premake 5.0 or later.

## See Also

* [path.isAbsolute](path.isAbsolute.md)
