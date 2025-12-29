Controls whether precompiled headers (PCH) are enabled for a configuration.

```lua
enablepch "value"
```

If no value is set for a configuration, the toolset's default behavior will be used.

### Parameters ###

`value` specifies the desired behavior:

| Value       | Description                                          |
|-------------|------------------------------------------------------|
| Default     | Use the toolset default behavior (Default value)     |
| On          | Enable precompiled headers                           |
| Off         | Disable precompiled headers                          |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

Disable precompiled headers for a debug configuration:

```lua
filter "configurations:Debug"
   enablepch "Off"
```

### See Also ###

* [pchheader](pchheader.md)
* [pchsource](pchsource.md)
