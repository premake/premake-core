Specifies a set of build platforms, which act as another configuration axis when building.

```lua
platforms { "names" }
```

The platforms listed here are just names to be displayed in the IDE, with no intrinsic meaning. A platform named "x86_64" will not create a 64-bit build; the appropriate architecture still must be specified. For more information, see [Configurations and Platforms](Configurations-and-Platforms.md).

### Parameters ###

`names` is a list of platform names. Spaces are allowed, but may make using certain Premake features, such as command-line configuration selection, more difficult.

### Applies To ###

Workspaces and projects.

### Availability ###

Premake 5.0 or later.

### Examples ###

Specify debug and release configurations for a workspace, with static and shared library "platforms" in 32- and 64-bit variations.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
  platforms { "Static32", "Shared32", "Static64", "Shared64" }

  filter "platforms:Static32"
    kind "StaticLib"
    architecture "x32"

  filter "platforms:Static64"
    kind "StaticLib"
    architecture "x64"

  filter "platforms:Shared32"
    kind "SharedLib"
    architecture "x32"

  filter "platforms:Shared64"
    kind "SharedLib"
    architecture "x64"
```


### See Also ###

* [Configurations and Platforms](Configurations-and-Platforms.md)
* [configurations](configurations.md)
