Enables Unity Builds in Visual Studio, also known as Jumbo Builds

```lua
enableUnityBuilds "value"
```

If no toolset is specified for a configuration, the system or IDE default will be used.

### Parameters ###

`value` is one of:
* `On`  - Enables Unity Builds.
* `Off` - Disables Unity Builds.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 and later. Versions are currently only implemented for Visual Studio 2019+.

### Examples ###

Enable Unity Builds.

```lua
enableUnityBuild "On"
```
