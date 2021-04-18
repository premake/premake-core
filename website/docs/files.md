Adds files to a project.

```lua
files { "file_list" }
```

### Parameters ###

`file_list` specifies one or more file patterns. File paths should be specified relative to the currently executing script file. File patterns may contain the `*` wildcard to match against files in the current directory, or the `**` wildcard to perform a recursive match.

If a wildcard matches more files than you would like, you may filter the results using the [removefiles()](Removing-Values.md) function.

### Applies To ###

Project configurations. [Not all exporters currently support](Feature-Matrix.md) per-configuration file lists however.

### Examples ###

Add two files from to the current project, from the same directory that contains the script.

```lua
files { "hello.cpp", "goodbye.cpp" }
```

Add all C++ files from the **src/** directory to the project.

```lua
files { "src/*.cpp" }
```

Add all C++ files from the **src/** directory and any subdirectories.

```lua
files { "src/**.cpp" }
```

Add files for specific systems; might not work with all exporters.

```lua
filter "system:Windows"
  files { "src/windows/*.h", "src/windows/*.cpp" }

filter "system:MacOSX"
  files { "src/mac/*.h", "src/mac/*.cpp" }
```


### See Also ###

* [Adding Source Files](Adding-Source-Files.md)
* [Removing Values](Removing-Values.md)
* [vpaths](vpaths.md)
