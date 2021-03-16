Controls the number of warnings that are shown by the compiler.

```lua
warnings "value"
```

If no value is set for a configuration, the toolset's default warning level will be used.

### Parameters ###

`value` specifies the desired level of warning:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Off         | Do not show any warning messages.                      |
| Default     | Use the toolset's default warning level.               |
| Extra       | Enable the toolset's maximum warning level.            |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.

### Examples ###

```lua
warnings "Extra"
```
