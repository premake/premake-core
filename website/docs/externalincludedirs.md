Specifies the include file search paths for the compiler, treating headers included from these paths as external.

```lua
externalincludedirs { "paths" }
```

For Visual Studio, these paths are placed in the "VC++ Directories" properties panel. For GCC and Clang, they are preceded with the `-isystem` flag, rather than `-I`. For toolsets which do not support the concept of external include directories, they are treated as a normal include directory.

Include files located via an external include directory are treated specially, see [externalwarnings](externalwarnings.md).

### Parameters ###

`paths` specifies a list of include file search directories. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Define two external include file search paths.

```lua
externalincludedirs { "../lua/include", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
externalincludedirs { "../includes/**" }
```

### See Also ###

* [externalanglebrackets](externalanglebrackets.md)
* [externalwarnings](externalwarnings.md)
* [includedirs](includedirs.md)
