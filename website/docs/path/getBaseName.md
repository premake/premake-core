---
title: path.getBaseName
---

Returns the base file portion of a path, with the directory and file extension removed.

```lua
baseName = path.getBaseName('path')
```

### Parameters

`path` is the file system path to be split.

### Return Value

The base name portion of the supplied path, with any directory and file extension removed.

### Availability

Premake 6.0 or later (available in 4.0 or later as `path.getbasename()`).

### See Also

* [path.getDirectory](getDirectory.md)
* [path.getName](getName.md)

### Examples

```lua
local path = require('path')

-- return 'file'
local baseName = path.getBaseName('/path/to/file.txt')
```
