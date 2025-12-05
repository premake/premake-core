---
title: debugdir
description: Specifies commands to be executed upon connection of the debugger to a remote process.
keywords: [premake, debugdir, debugger, commands, visual studio, project config]
---

Sets the working directory for the integrated debugger.

```lua
debugdir "path"
```

:::note
this settings is not implemented for Xcode, which requires a per-user configuration file in order to make it work.
:::

:::note
In Visual Studio, this file can be overridden by a per-user configuration file (such as `ProjectName.vcproj.MYDOMAIN-MYUSERNAME.user`).
:::

:::warning
Removing `ProjectName.vcproj.MYDOMAIN-MYUSERNAME.user` (which is done by Premake's clean action) will restore the default settings.
:::

### Parameters ###

`path` is the path to the working directory, relative to the currently executing script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.


### Examples ###

```lua
filter { "configurations:Debug" }
   debugdir "bin/debug"
```
