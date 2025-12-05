---
title: debugcommand
description: Specifies the command to launch a project's target when debugging.
keywords: [premake, debugargs, debugger, arguments, visual studio, project config]
---

Specifies the command to launch a project's target when debugging.

```lua
debugcommand ("command")
```
:::note
In Visual Studio, this file can be overridden by a per-user configuration file (such as `ProjectName.vcproj.MYDOMAIN-MYUSERNAME.user`).
:::

:::warning
Removing `ProjectName.vcproj.MYDOMAIN-MYUSERNAME.user` (which is done by Premake's clean action) will restore the default settings.
:::

### Parameters ###

`command` **string** - is the command to run to start the target.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [debugargs](debugargs.md)
* [debugdir](debugdir.md)
