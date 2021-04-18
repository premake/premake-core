Selects a .NET framework version.

```lua
framework ("version")
```

This value currently is only applied to Visual Studio 2005 or later, and GNU makefiles using Mono. If no framework is specified the toolset default is used.

### Parameters ###

`version` is one of:

 * 1.0
 * 1.1
 * 2.0
 * 3.0
 * 3.5
 * 4.0

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

Use the .NET 3.0 Framework.

```lua
framework "3.0"
```

### Remarks ###

This API is deprecated since 5.0, please use [dotnetframework](dotnetframework.md) instead.

### See Also ###

* [clr](clr.md)
* [dotnetframework](dotnetframework.md)