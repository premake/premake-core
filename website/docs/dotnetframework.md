Selects a .NET framework version.

```lua
dotnetframework ("version")
```

This value currently is only applied to Visual Studio 2005 or later, and GNU makefiles using Mono. If no .NET framework version is specified the toolset default is used.

### Parameters ###

`version` is one of:

| Version | Documentation |
| 1.0 | .NET Framework 1.0 |
| 1.1 | .NET Framework 1.1 |
| 2.0 | .NET Framework 2.0 |
| 3.0 | .NET Framework 3.0 |
| 3.5 | .NET Framework 3.5 |
| 4.0 | .NET Framework 4.0 |
| 4.5 | .NET Framework 4.5 |
| 4.6 | .NET Framework 4.6 |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Use the .NET framework 3.0.

```lua
dotnetframework "3.0"
```

### See Also ###

* [clr](clr.md)
