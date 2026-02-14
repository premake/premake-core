Used to specify the NuGet package source. Only NuGet "galleries" are currently supported. Defaults to the official NuGet Gallery at nuget.org.

```lua
nugetsource ("url")
```

### Parameters ###

`url` is the NuGet v3 feed URL or local directory.

### Applies To ###

Project configurations.

### Availability ###

Nuget "galleries" since Premake 5.0.0-alpha12 or later.
Local directory since Premake 5.0.0 or later.

### Examples ###

Set source to NuGet gallery.

```lua
nugetsource "https://api.nuget.org/v3/index.json"
```

Set source to local directory.

```lua
nugetsource "c:/my_nuget_packages/"
```
### See Also ###

* [nuget](nuget.md)
