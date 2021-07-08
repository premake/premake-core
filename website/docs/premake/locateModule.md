---
title: premake.locateModule
---

Locate a module on [Premake's script search path](../authoring/locating-scripts.md).

```lua
path = premake.locateModule('moduleName')
```

### Parameters

`moduleName` is the name of the module to locate. It should usually not include the file extension (i.e. `.lua`), but may include some path information, e.g. `xcode/xcode.lua` if appropriate to properly identify the module on the file system.

### Return Value

The full absolute path to the module script if found, or `nil` if the module could not be located.

### Availability

Premake 6.0 or later.

### See Also

- [premake.locateScript](locateScript.md)
