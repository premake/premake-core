# path.getDirectory

Returns the directory portion of a path, with any file name removed.

```lua
local path = require('path')
local result = path.getDirectory('value')
```

## Parameters

`value` is the path to be split.

## Return Value

The directory portion of the path, with any file name removed. If the path does not include any directory information, the "." (single dot) current directory is returned.

## Availability

Premake 6.0 or later (available in 4.0 or later as `path.getdirectory`).
