Sets the directory where object and other intermediate files should be placed when building a project.

```lua
objdir ("path")
```

By default, intermediate files will be stored in a directory named "obj" in the same directory as the project. The `objdir` function allows you to change this location.

To avoid conflicts between build configurations, Premake will ensure that each intermediate directory is unique by appending one or more of the build configuration name, platform name, or project name. You may use the "!" prefix to prevent this behavior, and allow overlapping intermediate directories. See the examples below for more information.


### Parameters ###

`path` is the directory where the object and intermediate files should be stored, specified relative to the currently executing script file. [Tokens](Tokens.md) maybe be used.


### Applies To ###

Project configurations.


### Availability ###

Premake 4.0 or later. The "!" prefix was introduced in Premake 5.0.


### Examples ###

Use a directory named "obj" (the default) for intermediate files. Actual directories will be `obj/Debug` and `obj/Release`.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }

project "MyProject"
   objdir "obj"
```

Use a directory named "obj" (the default) for intermediate files. Actual directories will be `obj/Debug/x32`, `obj/Debug/x64`, `obj/Release/x32`, and `obj/Release/x64`.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "x32", "x64" }

project "MyProject"
   objdir "obj"
```

Use tokens to reformat the path. Since the end result is unique, Premake will not append any extra directories. Actual directories will be `obj/x32_Debug`, `obj/x64_Debug`, `obj/x32_Release`, and `obj/x64_Release`.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "x32", "x64" }

project "MyProject"
   objdir "obj/%{cfg.platform}_%{cfg.buildcfg}"
```

Use the "!" prefix to force a specific directory using Visual Studio's provided environment variables instead of Premake tokens.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "x32", "x64" }

project "MyProject"
   objdir "!obj/$(Platform)_$(Configuration)"
```
