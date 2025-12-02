---
title: buildstlmodules
description: Sets whether or not the compiler should build STL modules.
keywords: [premake, buildstlmodules, stl modules, visual studio, compiler, config]
---

Sets whether or not the compiler should build STL modules.

```lua
buildstlmodules("enabled")
```

### Parameters ###

| Enabled | Description         |
| ------- | ------------------- |
| On      | Enable stl modules  |
| Off     | Disable stl modules |


### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 3 or later for Visual Studio 2022 and later.

### See Also ###

* [enablemodules](enablemodules.md)
