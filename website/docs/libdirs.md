Specifies the library search paths for the linker.

```lua
libdirs { "paths" }
```

Library search directories are not well supported by the .NET tools. Visual Studio will change relative paths to absolute, making it difficult to share the generated project. MonoDevelop does not support search directories at all, using only the GAC. In general, it is better to include the full (relative) path to the assembly in [links](links.md) instead. C/C++ projects do not have this limitation.

### Parameters ###

`paths` specifies a list of library search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Define two library file search paths.

```lua
libdirs { "../lua/libs", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
libdirs { "../libs/**" }
```
