# path.getBaseName

Returns the base file portion of a path, with the directory and file extension removed.

```lua
path = require('path')
basename = path.getBaseName('path')
```

## Parameters

`path` is the file system path to be split.

## Return Value

The base name portion of the supplied path, with any directory and file extension removed.

## Availability

Premake 6.0 or later (available in 4.0 or later as `path.getbasename`).

## See Also

* [path.getDirectory](path.getDirectory.md)
* [path.getName](path.getName.md)
