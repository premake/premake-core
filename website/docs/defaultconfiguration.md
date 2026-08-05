Specifies the default build configuration for a workspace.

```lua
defaultconfiguration ("configuration_name")
```

If a default configuration is not specified through this API, the first configuration in alphabetical order from `configurations` will be used as the default.

### Parameters ###

`configuration_name` - The name of the build configuration to use as default.

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0.0 or later.

### Examples ###

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
  defaultconfiguration "Release"
```

When combined with [`defaultplatform`](defaultplatform.md), Premake will prefer the configuration/platform pair that matches both settings.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
  platforms { "x86", "x64" }
  defaultconfiguration "Release"
  defaultplatform "x64"
```

### Remarks ###

When generating Visual Studio solutions (`.sln` or `.slnx`), Premake writes the selected build configuration and platform first. Neither Microsoft solution format provides fields that explicitly identify the default configuration or platform, so this is a best-effort hint based on entry ordering. Microsoft tools or other consumers may apply their own defaults instead; for example, MSBuild prefers `Debug` when that configuration exists.

### See Also ###

* [configurations](configurations.md)
* [defaultplatform](defaultplatform.md)
