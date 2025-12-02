---
title: configurations
description: Specifies the set of build configurations.
keywords: [premake, configurations, debug, release]
---

Specifies the set of build configurations, such as "Debug" and "Release", for a workspace or project.

```lua
configurations { "names" }
```

A configuration encapsulates a collection of build settings, allowing the developer to easily switch between them. "Debug" and "Release" are the most common configuration names.

For more information, see [Configurations and Platforms](Configurations-and-Platforms.md).

### Parameters ###

`names` **string[]** - is a list of configuration names. Spaces are allowed, but may make using certain Premake features, such as a command-line configuration selection, more difficult.

### Applies To ###

Workspaces and projects.

### Availability ###

Premake 4.0 or later. Per-project configuration lists were introduced in Premake 5.0.

### Examples ###

Specify debug and release configurations for a workspace.

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }
```

Add additional configurations for a dynamic link library version.

```lua
configurations { "Debug", "Release", "DebugDLL", "ReleaseDLL" }
```


## See Also ##

* [Configurations and Platforms](Configurations-and-Platforms.md)
* [platforms](platforms.md)
