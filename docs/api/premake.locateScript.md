# premake.locateScript

Locate a file on [Premake's script search path](_PREMAKE.PATH.md).

```lua
premake = require('premake')
path = premake.locateScript('filename')
```

## Parameters

`filename` is the name of the script to locate. It should include the file extension (i.e. `.lua`) and may include some path information, e.g. `xcode/xcode.lua`.

## Return Value

The full absolute path to the file if found, or `nil` if the file could not be located.

## Availability

Premake 6.0 or later.

## See Also

- [premake.locateModule](premake.locateModule.md)
