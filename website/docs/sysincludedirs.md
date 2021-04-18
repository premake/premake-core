Specifies the system include file search paths.

```lua
sysincludedirs { "paths" }
```

For Visual Studio, these paths are placed in the "VC++ Directories" properties panel. For GCC and Clang, they are preceded with the `-isystem` flag, rather than `-I`. For toolsets which do not support the concept of system include directories, they are treated as a normal include directory.

Include files located via a system include directory are treated as correct: no warnings will be shown for the contents of the file.

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

* [includedirs](includedirs.md)
* [syslibdirs](syslibdirs.md)
