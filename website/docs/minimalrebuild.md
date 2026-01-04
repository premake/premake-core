Sets the minimal rebuild option for Visual Studio projects. This feature was deprecated by Microsoft in Visual Studio 2015 and later versions. When enabled, minimal rebuild allows the compiler to recompile only the source files that are affected by changes to C++ class definitions.

```lua
minimalrebuild ("value")
```

### Parameters ###

`value` is one of:

| Value     | Description                                                     |
|-----------|-----------------------------------------------------------------|
| `Default` | Uses the default behavior for the toolset.                      |
| `On`      | Enables minimal rebuild (Visual Studio 2015 and earlier only).  |
| `Off`     | Disables minimal rebuild.                                       |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later for Visual Studio 2015 and earlier.

### Examples ###

```lua
minimalrebuild "Off"
```
