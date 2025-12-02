---
title: configmap
description: Map workspace level configuration and platforms to a different project configuration or platform.
keywords: [premake, configmap, configuration mapping, platforms]
---

Map workspace level configuration and platforms to a different project configuration or platform.

```lua
configmap {
   [{ wks_cfg }] = { prj_cfg },
```

You may map multiple configurations in a single configuration map.

### Parameters ###

`wks_cfg` **string | table** - is the workspace configuration being mapped. It can be a string representing a build configuration or a platform, or a table holding a build configuration/platform pair.

`prj_cfg` **string | table** - is the project configuration to which the workspace configuration should be mapped. It may also be a string or a build configuration/platform pair.

### Applies To ###

Projects.

### Availability ###

5.0 or later.

### Examples ###

The workspace contains four build configurations, while the project contains only the standard Debug and Release. Map the extra workspace configurations to Debug and Release.


```lua
workspace "MyWorkspace"
   configurations { "Debug", "Development", "Profile", "Release" }

project "MyProject"
   configmap {
      ["Development"] = "Debug",
      ["Profile"] = "Release",
   }
```

It can be useful to specify a map globally for a workspace, but only apply it if the target configuration is actually present in the project. In this example, host executables can be built for either Windows or Mac, while some projects build for an embedded controller. Any project that uses the special "Embedded" platform will receive the configuration map.


```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   platforms { "Windows", "Mac" }

   filter { "platforms:Embedded" }
      configmap {
         ["Windows"] = "Embedded",
         ["Mac"] = "Embedded"
      }

-- this project gets the configuration map, because it defines an "Embedded" platform
project "MyEmbeddedProject"
   platforms { "Embedded" }

-- this one does not
project "MyHostProject"
```

### See Also ###

* [Configurations and Platforms](Configurations-and-Platforms.md)
