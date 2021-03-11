Selects a .NET framework version.

```lua
dotnetframework ("version")
```

This value currently is only applied to Visual Studio 2005 or later, and GNU makefiles using Mono. If no .NET framework version is specified the toolset default is used.

### Parameters ###

`version` is one of:

 * 1.0
 * 1.1
 * 2.0
 * 3.0
 * 3.5
 * 4.0
 * 4.5
 * 4.6

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

Use the .NET framework 3.0.

```lua
dotnetframework "3.0"
```

### See Also ###

* [clr](clr.md)
* [framework](framework.md)