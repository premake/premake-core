Sets the minimal rebuild option for Visual Studio projects. This feature was deprecated by Microsoft in Visual Studio 2015 and later versions. When enabled, minimal rebuild allows the compiler to recompile only the source files that are affected by changes to C++ class definitions.

```lua
minimalrebuild ("value")
```

### Allowed values ###

| Value     | Description                                                     |
|-----------|-----------------------------------------------------------------|
| `Default` | Uses the default behavior for the toolset.                      |
| `On`      | Enables minimal rebuild (Visual Studio 2015 and earlier only).  |
| `Off`     | Disables minimal rebuild.                                       |

### Applies To ###

The `config` scope.

### Availability ###

Visual Studio 2015 and earlier.

### Examples ###

```lua
minimalrebuild "Off"
```
