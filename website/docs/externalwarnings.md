Controls the level of warnings that are shown by the compiler for headers that are considered external.

```lua
externalwarnings ("value")
```

If no value is set for a configuration, the toolset's default warning level will be used.

### Parameters ###

`value` specifies the desired level of warning:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Off         | Do not show any warning messages.                      |
| Default     | Use the toolset's default warning level.               |
| Extra       | Enable the toolset's maximum warning level.            |
| High        | Enable the toolset's maximum warning level.            |
| Everything  | Enable the toolset's maximum warning level.            |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio 2019+.

### Examples ###

```lua
externalwarnings "Off"
```

### See Also ###

* [externalanglebrackets](externalanglebrackets.md)
* [externalincludedirs](externalincludedirs.md)
* [warnings](warnings.md)
