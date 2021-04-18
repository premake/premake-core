Specifies the file search paths for `using` statements.

```lua
usingsdirs { "paths" }
```

### Parameters ###

`paths` specifies a list of file search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

Define two using file search paths.

```lua
usingdirs { "../lib1", "../lib2" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
usingdirs { "../libs/**" }
```

### See Also ###

* [includedirs](includedirs.md)
