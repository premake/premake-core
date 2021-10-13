Controls the number of warnings that are shown by the compiler. This setting only applies to Visual Studio 17 and newer. It will control the warnings shown for includes given by [sysincludedirs](sysincludedirs.md).

```lua
externalwarnings "value"
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

Premake 5.0

### Examples ###

```lua
externalwarnings "Extra"
```

### See Also ###
* [sysincludedirs](sysincludedirs.md)