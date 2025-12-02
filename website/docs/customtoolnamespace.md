---
title: customtoolnamespace
description: Sets the namespace used by custom build tools in Visual Studio .NET projects.
keywords: [premake, customtoolnamespace, visual studio, .net, msbuild, custom tool, namespace]
---

Sets the namespace used by custom build tools in Visual Studio .NET projects.
```lua
customtoolnamespace "value"
```

Only used by Visual Studio .NET targets.

Maps to `<CustomToolNamespace>` MSBuild element.

### Parameters ###

`value` - needs documentation.

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
customtoolnamespace "value"
```

