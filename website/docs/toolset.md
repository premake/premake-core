Selects the compiler, linker, etc. which are used to build a project or configuration.

```lua
toolset ("identifier")
```

If no toolset is specified for a configuration, the system or IDE default will be used.

### Parameters ###

`identifier` is a string identifier for the toolset. Premake includes the following toolsets by default.

| **Toolset identifier**   |  **Description**                                |
|------------|---------------------------------------------------------------|
| `clang`    | [Clang](http://clang.llvm.org)                                |
| `dotnet`   | The system's default C# compiler                              |
| `gcc`      | [GNU Compiler Collection](https://gcc.gnu.org)                |
| `msc`      | Microsoft C/C++ compiler                                      |

If a specific toolset version is desired, it may be specified as part of the identifer, separated by a dash. See the examples below.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 and later. Versions are currently only implemented for Visual Studio 2010+.

### Examples ###

Specify version 110 of the Windows platform toolset.

```lua
toolset "msc-v110" -- or...
toolset "v100"    -- for those more familiar with Visual Studio's way
```

Use [Clang/C2](http://llvm.org/builds/) with Visual Studio
```lua
toolset "msc-llvm-vs2014" -- pre VS 2019
toolset "clang" -- VS 2019 and newer
```

Use the toolset for Windows XP
```lua
toolset "v140_xp"
```
