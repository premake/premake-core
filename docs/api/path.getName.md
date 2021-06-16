# path.getName

Returns the file name and extension, with any directory information removed.

```lua
path = require('path')
name = path.getName('path')
```

## Parameters

`path` is the file system path to be split.

## Return Value

The file name and extension, with no directory information.

## Availability

Premake 6.0 or later (available in 4.0 or later as `path.getname`).

## See Also

* [path.getBaseName](path.getBaseName.md)
* [path.getDirectory](path.getDirectory.md)
