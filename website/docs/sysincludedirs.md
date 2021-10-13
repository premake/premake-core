Specifies the system include file search paths.

```lua
sysincludedirs { "paths" }
```

For Visual Studio, these paths are placed in the "VC++ Directories" properties panel under "External Include Directories". Note that unlike gcc and clang this does not control warning levels. See externalwarnings to control the warning level for sysincludes in visual studio.

For GCC and Clang, they are preceded with the `-isystem` flag, rather than `-I`. For toolsets which do not support the concept of system include directories, they are treated as a normal include directory.

Include files located via a system include directory are treated as correct: no warnings will be shown for the contents of the file.
Note that this is different for Visual Studio.

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
* [externalwarnings](externalwarnings.md)
