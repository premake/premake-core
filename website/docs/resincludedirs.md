Specifies the include file search paths for the resource compiler.

```lua
resincludedirs { "paths" }
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
resincludedirs { "../lua/include", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
resincludedirs { "../includes/**" }
```