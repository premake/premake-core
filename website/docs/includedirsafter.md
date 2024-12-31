Specifies the include directories to parse last per the toolset ordering and marks the directory as an external include directory.  If the exporter or toolset
does not support include directory ordering, these directories are added to the external include directory path.

```lua
includedirsafter { "paths" }
```

### Parameters ###

`paths` specifies a list of include file search directories. Paths should be specified relative to the currently running script file.  Search order is evaluated from left
to right.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

GCC and Clang are the only toolsets supporting the ordering functionality in the gmakelegacy, gmake, and Codelite exporters.  All exporters and toolsets
support appending the directories to the external include directories.

### Examples ###

Define two include file search paths.

```lua
includedirsafter { "../lua/include", "../zlib" }
```

You can also use wildcards to match multiple directories. The * will match against a single directory, ** will recurse into subdirectories as well.

```lua
includedirsafter { "../includes/**" }
```

### See Also ###

* [includedirs](includedirs.md)
* [externalincludedirs](externalincludedirs.md)
