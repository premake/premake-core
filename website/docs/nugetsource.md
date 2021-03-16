Used to specify the NuGet package source. Only NuGet "galleries" are currently supported. Defaults to the official NuGet Gallery at nuget.org.

```lua
nugetsource "url"
```

### Parameters ###

`url` is the NuGet v3 feed URL.

### Applies To ###

The `project` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
nugetsource "https://api.nuget.org/v3/index.json"
```

### See Also ###

* [nuget](nuget.md)
