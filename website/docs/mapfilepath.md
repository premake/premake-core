Specifies the path to generate a mapfile at.

```lua
mapfilepath ("path")
```

If `mapfile` is not `"On"`, then no mapfile will be generated. If `mapfile` is `"On"` but this value is not set, this will generate a mapfile at a default location,
as determined by either the toolset or exporter.

### Parameters ###

`path` specifies the desired mapfile path

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later on Visual Studio.

### See Also ###

* [mapfile](mapfile.md)
