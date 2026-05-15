Selects a .NET framework version(s).

```lua
dotnetframework (versions)
```

This value currently is only applied to Visual Studio 2005 or later, and GNU makefiles using Mono. If no .NET framework version is specified the toolset default is used.

### Parameters ###

`versions` is a list of version name strings where each element is one of:

| Version | Documentation |
| X.X | .NET Framework X.X |
| netcoreappX.X | .NET Core X.X |
| netstandardX.X | .NET Standard X.X |
| netX.X | .NET X.X |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Use .NET 10.0:

```lua
dotnetframework "net10.0"
```

Use .NET 8.0 and .NET 10.0:

```lua
dotnetframework { "net8.0", "net10.0" }
```

Use .NET Core 2.1:

```lua
dotnetframework "netcoreapp2.1"
```

Use .NET Standard 2.1:

```lua
dotnetframework "netstandard2.1"
```


Use the .NET framework 4.6:

```lua
dotnetframework "4.6"
```

### See Also ###

* [clr](clr.md)
