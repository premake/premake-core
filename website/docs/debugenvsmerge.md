Specifies whether to merge debug environment variables with the system environment.

```lua
debugenvsmerge ("value")
```

When set to `Off`, only the [debugenvs](debugenvs.md) you specify will be used, preventing them from being merged with the existing system environment. This is useful when you want complete control over the debug environment.

### Parameters ###

`value` specifies the merge behavior:

| Value       | Description                                              |
|-------------|----------------------------------------------------------|
| Default     | Use the toolset's default behavior (merge enabled)       |
| On          | Merge debug environment with system environment          |
| Off         | Do not merge with system environment                     |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

Set debug environment variables without merging with system environment:

```lua
filter "configurations:Debug"
  debugenvs { "PATH=C:\\custom\\bin", "MY_VAR=value" }
  debugenvsmerge "Off"
```

Explicitly enable merging (default behavior):

```lua
filter "configurations:Debug"
  debugenvs { "EXTRA_VAR=1" }
  debugenvsmerge "On"
```

### See Also ###

* [debugenvs](debugenvs.md)
* [debugenvsinherit](debugenvsinherit.md)
