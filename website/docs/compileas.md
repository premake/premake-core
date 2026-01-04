Specifies how to treat a file for compilation.

```lua
compileas ("value")
```

### Parameters ###

`value` is one of:

| Value | Description | Notes |
|-------|-------------|-------|
| Default | Compile based on file extensions built into Premake. |
| C | Compile as a C source file. |
| C++ | Compile as a C++ source file. |
| Objective-C | Compile as an Objective-C source file. |
| Objective-C++ | Compile as an Objective-C++ source file. |
| Module | Compile as a C++20 module interface unit. | Premake 5.0.0-beta1 for Visual Studio 2019+ |
| ModulePartition | Compile as a C++20 module interface partition. | Premake 5.0.0-beta1 for Visual Studio 2019+ |
| HeaderUnit | Compile as a C++20 header unit. | Premake 5.0.0-beta1 for Visual Studio 2019+ |

### Applies To ###

Workspace, project, and file configuration scopes.

### Availability ###

Premake 5.0.0-alpha13 or later.

### Examples ###

```lua
filter { "files:**.c" }
    compileas "C++"
```

