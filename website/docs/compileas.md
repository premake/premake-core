---
title: compileas
description: Specify how a source file should be compiled, regardless of its extension.
keywords: [premake, compileas, compile type]
---

Specify how a source file should be compiled, regardless of its extension.

```lua
compileas "type"
```

### Parameters ###

| Type            | Description                                                         |
| --------------- | ------------------------------------------------------------------- |
| Default         | Compile based on file extensions that have been built into Premake. |
| C               | Compile as a C source file.                                         |
| C++             | Compile as a C++ source file.                                       |
| Objective-C     | Compile as an Objective-C source file.                              |
| Objective-C++   | Compile as an Objective-C++ source file.                            |
| Module          | Compile as a C++20 module interface unit.                           |
| ModulePartition | Compile as a C++20 module interface partition.                      |
| HeaderUnit      | Compile as a C++20 header unit.                                     |


### Applies To ###

The `workspace`, `project` or `file` scope.

### Availability ###

Premake 5.0.0 alpha 13 or later. The options **Module**, **ModulePartition** and **HeaderUnit** are only available in Premake 5.0-beta1 or later and only implemented for Visual Studio 2019+.

### Examples ###

```lua
filter { "files:**.c" }
    compileas "C++"
```

