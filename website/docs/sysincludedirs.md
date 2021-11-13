Alias of [externalincludedirs](externalincludedirs.md).

```lua
sysincludedirs { "paths" }
```

**This function has been deprecated in Premake 5.0 beta2.** Use the new [externalincludedirs](externalincludedirs.md) function instead. `sysincludedirs` will be not supported in Premake 6.

### Parameters ###

*paths* specifies a list of include file search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

Define two system include file search paths.

```lua
sysincludedirs { "../lua/include", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
sysincludedirs { "../includes/**" }
```

### See Also ###

* [externalincludedirs](externalincludedirs.md)
