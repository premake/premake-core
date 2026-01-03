Specifies the default build platform for a workspace.

```lua
defaultplatform ("platform_name")
```

If `platform_name` has not been defined using [`platforms`](platforms.md) the default platform will not change from the generic one i.e. the first one passed to [`platforms`](platforms.md).

### Parameters ###

`platform_name` - Is the name of the platform you want to use as default.

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
  platforms { "Static32", "Shared32", "Static64", "Shared64" }
  defaultplatform "Shared64" -- Default platform from "Static32" to "Shared64"

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

* [platforms](platforms.md)
