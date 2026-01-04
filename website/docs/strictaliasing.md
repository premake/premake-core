Sets the level of allowed pointer aliasing.

```lua
strictaliasing ("value")
```

If no value is set for a configuration, the toolset's settings will be used.

### Parameters ###

`value` specifies the desired level of optimization:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Off         | No strict aliasing tests will be performed.            |
| Level1      |                                                        |
| Level2      |                                                        |
| Level3      |                                                        |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1.

### Examples ###

```lua
strictaliasing "Level1"
```
