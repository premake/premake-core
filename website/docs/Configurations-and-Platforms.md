---
title: Configurations & Platforms
---

A *configuration* is a collection of settings to apply to a build, including flags and switches, header file and library search directories, and more. Each workspace defines its own list of configuration names; the default provided by most IDEs is "Debug" and "Release".

## Build Configurations

The [previous examples](Your-First-Script.md) showed how to specify build configurations.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
```

You are not limited to these names, but can use whatever makes sense to your software project and build environment. For instance, if your project can be built as both static or shared libraries, you might use this instead:

```lua
workspace "MyWorkspace"
   configurations { "Debug", "DebugDLL", "Release", "ReleaseDLL" }
```

It is important to note that these names have no meaning in and of themselves, and that you can use whatever names you like.

```lua
workspace "MyWorkspace"
   configurations { "Froobniz", "Fozbat", "Cthulhu" }
```

The meaning of the build configuration depends on the settings you apply to it, as shown in [the earlier examples](Your-First-Script.md).

```lua
workspace "HelloWorld"
   configurations { "Debug", "Release" }

   filter "configurations:Debug"
      defines { "DEBUG" }
      flags { "Symbols" }

   filter "configurations:Release"
      defines { "NDEBUG" }
      optimize "On"
```

The [Filters](Filters.md) section will cover this in more detail.


## Platforms

"Platforms" is a bit of a misnomer here; once again I am following the Visual Studio nomenclature. Really, platforms are just another set of build configuration names, providing another axis on which to configure your project.

```lua
configurations { "Debug", "Release" }
platforms { "Win32", "Win64", "Xbox360" }
```

Once set, your listed platforms will appear in the Platforms list of your IDE. So you can choose a "Debug Win32" build, or a "Release Xbox360" build, or any combination of the two lists.

Just like the build configurations, the platform names have no meaning on their own. You provide meaning by applying settings using the [`filter`](filter.md) function.

```lua
configurations { "Debug", "Release" }
platforms { "Win32", "Win64", "Xbox360" }

filter { "platforms:Win32" }
    system "Windows"
    architecture "x86"

filter { "platforms:Win64" }
    system "Windows"
    architecture "x86_64"

filter { "platforms:Xbox360" }
    system "Xbox360"
```

Unlike build configurations, platforms are completely optional. If you don't need them, just don't call the platforms function at all and the toolset's default behavior will be used.

Platforms are just another form of build configuration. You can use all of the same settings, and the same scoping rules apply. You can use the [`system`](system.md) and [`architecture`()`](architecture.md) settings without platforms, and you can use otherwise non-platform settings in a platform configuration. If you've ever done build configurations like "Debug Static", "Debug DLL", "Release Static", and "Release DLL", platforms can really simplify things.

```lua
configurations { "Debug", "Release" }
platforms { "Static", "DLL" }

filter { "platforms:Static" }
    kind "StaticLib"

filter { "platforms:DLL" }
    kind "SharedLib"
    defines { "DLL_EXPORTS" }
```

## Per-Project Configurations

Configurations and platform lists may now be specified per-project. As an example, a project that should build for Windows, but not for a game console, can remove that platform:

```lua
workspace "MyWorkspace"
    configurations { "Debug", "Release" }
    platforms { "Windows", "PS3" }

project "MyProject"
    removeplatforms { "PS3" }
```

A related feature, configuration maps, translate a workspace-level configuration to project-level values, allowing projects with different configuration and platform lists to be combined in a single workspace. For example, a unit test library might be configured with the generic debug and release configurations.

```lua
project "UnitTest"
    configurations { "Debug", "Release" }

```

To reuse that test project in a workspace which contains a more complex set of configurations, create a mapping from the workspace's configurations to the corresponding project configuration.

```lua
workspace "MyWorkspace"
    configurations { "Debug", "Development", "Profile", "Release" }

project "UnitTest"
    configmap {
        ["Development"] = "Debug",
        ["Profile"] = "Release"
    }
```

It is important to note that projects can't *add* new configurations to the workspace. They can only remove support for existing workspace configurations, or map them to a different project configuration.
