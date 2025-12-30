Controls whether the linker uses relative or absolute paths for library references.

```lua
userelativelinks ("value")
```

If no value is set for a configuration, the toolset's default behavior will be used.

### Parameters ###

`value` specifies the desired behavior:

| Value       | Description                                          |
|-------------|------------------------------------------------------|
| Default     | Use the toolset default behavior (Default value)     |
| On          | Use relative paths for library references            |
| Off         | Use absolute paths for library references            |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later. Replaces the deprecated `RelativeLinks` flag.

### Examples ###

Use relative paths for library linking:

```lua
userelativelinks "On"
```

### See Also ###

* [links](links.md)
* [libdirs](libdirs.md)
