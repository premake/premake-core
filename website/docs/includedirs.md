Specifies the include file search paths for the compiler.

```lua
includedirs { "paths" }
```

### Parameters ###

`paths` specifies a list of include file search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Define two include file search paths.

```lua
includedirs { "../lua/include", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
includedirs { "../includes/**" }
```

### See Also ###

* [libdirs](libdirs.md)
