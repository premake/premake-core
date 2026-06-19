Specifies the default build platform for a workspace.

```lua
defaultplatform ("platform_name")
```

If a default platform is not specified through this API, the first platform in alphabetical order from `platforms` will be used as the default.

### Parameters ###

`platform_name` - The name of the platform to use as default.

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

* [defaultconfiguration](defaultconfiguration.md)
* [platforms](platforms.md)
