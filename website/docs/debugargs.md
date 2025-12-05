---
title: debugargs
description: Specifies a list of arguments to pass to the application when run under the debugger.
keywords: [premake, debugargs, debugger, arguments, visual studio, project config]
---

Specifies a list of arguments to pass to the application when run under the debugger.

```lua
debugargs { "args" }
```

Note that this setting is not implemented for Xcode 3, which requires a per-user configuration file in order to make it work.

In Visual Studio, this file can be overridden by a per-user configuration file (such as `ProjectName.vcproj.MYDOMAIN-MYUSERNAME.user`). Removing this file (which is done by Premake's clean action) will restore the default settings.

### Parameters ###

`args` **string** - is a list of arguments to provide to the executable while debugging.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
filter { "configurations:Debug" }
   debugargs { "--append", "somefile.txt" }
```
