---
title: consumewinrtextension
description: Enables the WinRT extension.
keywords: [premake, consumewinrtextension, winrt, c++/cx, visual studio, compiler options]
---

Enables the WinRT extension, C++/CX, for the specified projects/files.

```lua
consumewinrtextension "value"
```

### Parameters ###

| Value   | Description                                                                 |
|---------|-----------------------------------------------------------------------------|
| Default | Compiles the file using the default for the toolset. (Default is `Off`)     |
| On      | Compiles the file with the WinRT extension enabled.                         |
| Off     | Compiles the file without the WinRT extension enabled.                      |

### Applies To ###

The `workspace`, `project` or `file` scope.

### Availability ###

Premake 5.0.0 Beta 2 or later and only implemented for Visual Studio 2019+.

### Examples ###

```lua
filter { "files:**_winrt.cpp" }
    consumewinrtextension "On"
```

