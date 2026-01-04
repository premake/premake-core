Specifies a list of NuGet packages that this project depends on. Only supported in Visual Studio C++ and C# projects.

```lua
nuget { "references" }
```

### Parameters ###

`references` is a list of NuGet package names and versions, where the version is separated from the name with a colon.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Link against some NuGet packages.

```lua
project "foo"
   nuget { "sdl2.v140:2.0.4", "sdl2.v140.redist:2.0.4" }
```

### See Also ###

* [nugetsource](nugetsource.md)
