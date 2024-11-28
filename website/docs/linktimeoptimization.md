The **linktimeoptimization** function specifies whether or not the toolset should perform link time optimization.

```lua
linktimeoptimization "value"
```

### Parameters ###

*value* specifies whether or not to use link time optimization, if the toolset and exporter support it.

| Value   | Description                                            |
|---------|--------------------------------------------------------|
| Off     | No LTO to be performed.                                |
| On      | LTO optimization enabled.                              |
| Default | Default LTO optimizations for the toolset or exporter. |

### Applies To ###

Project configurations

### Availability ###

Premake 5.0-beta4 and later