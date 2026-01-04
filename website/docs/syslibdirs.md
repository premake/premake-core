Specifies the system library search paths.

```lua
syslibdirs { "paths" }
```

For Visual Studio, these paths are placed in the "VC++ Directories" properties panel. For all other tools they are treated as a normal library search path.

### Parameters ###

`paths` specifies a list of library search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Define two system library search paths.

```lua
syslibdirs { "../lua/libs", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
syslibdirs { "../libs/**" }
```

### See Also ###

* [externalincludedirs](externalincludedirs.md)
* [libdirs](libdirs.md)
