compileas

```lua
compileas "value"
```

### Parameters ###

`value` one of:
* `Default` - Compile based on file extensions that have been built into premake.
* `C` - Compile as a C source file.
* `C++` - Compile as a C++ source file.
* `Objective-C` - Compile as an Objective-C source file.
* `Objective-C++` - Compile as an Objective-C++ source file.
* `Module` - Needs documentation
* `ModulePartition` - Needs documentation
* `HeaderUnit` - Needs documentation

### Applies To ###

The `workspace`, `project` or `file` scope.

### Availability ###

Premake 5.0.0 alpha 13 or later.

### Examples ###

```lua
filter { "files:**.c" }
    compileas "C++"
```

