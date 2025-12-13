The **linktimeoptimization** function specifies whether or not the toolset should perform link time optimization.

```lua
linktimeoptimization "value"
```

### Parameters ###

*value* specifies whether or not to use link time optimization, if the toolset and exporter support it.

| Value   | Description                                            | Notes |
|---------|--------------------------------------------------------| ---------------- |
| Off     | No LTO to be performed.                                |
| On      | LTO enabled.                                           |
| Fast    | Incremental/Fast LTO enabled.                          | Visual Studio & Clang only, available from Premake 5.0-beta8 or later |
| Default | Default LTO setting for the toolset or exporter.       |

### Applies To ###

Project configurations

### Availability ###

Premake 5.0-beta4 and later