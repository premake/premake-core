Enables the WinRT extension, C++/CX, for the specified projects/files.

```lua
consumewinrtextension ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Default | Compiles the file with the default for the toolset. |
| On | Compiles the file with the WinRT extension enabled. |
| Off | Compiles the file without the WinRT extension enabled. |

### Applies To ###

Workspace, project, and file configurations.

### Availability ###

Premake 5.0.0-beta2 and later for Visual Studio 2019+.

### Examples ###

```lua
filter { "files:**_winrt.cpp" }
    consumewinrtextension "On"
```

