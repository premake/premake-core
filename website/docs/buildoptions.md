---
title: buildoptions
description: Passes arguments directly to the compiler command line without translation.
keywords: [premake, buildoptions, compiler flags, command line, gmake, project config]
---

Passes arguments directly to the compiler command line without translation.

```lua
buildoptions { "options" }
```
:::warning
If a project includes multiple calls to `buildoptions` the lists are concatenated, in the order in which they appear in the script.
:::

### Parameters ###

`options` **string[]** - is a list of compiler flags and options, specific to a particular compiler.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

:::warning
Use `pkg-config` style configuration when building on Linux with GCC. Build options are always compiler specific and should be targeted to a particular toolset.
:::

```lua
filter { "system:linux", "action:gmake" }
  buildoptions { "`wx-config --cxxflags`", "-ansi", "-pedantic" }
```
