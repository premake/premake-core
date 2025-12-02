---
title: buildlog
description: Specifies the output location of a toolset's build logs.
keywords: [premake, buildlog, build logs, visual studio, project config, path]
---

Specifies the output location of a toolset's build logs.

```lua
buildlog("path")
```

If a build log path has not been specified, the toolset's default path will be used.

### Parameters ###

`path` **string** - is the output file system location for the build log file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later. Currently only implemented for Visual Studio 2010+.
