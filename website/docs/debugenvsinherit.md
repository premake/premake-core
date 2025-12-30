Specifies whether to inherit the parent environment when using debug environment variables.

```lua
debugenvsinherit ("value")
```

When set to `On`, the parent environment variables will be included alongside any custom [debugenvs](debugenvs.md) you specify. In Visual Studio, this appends `$(LocalDebuggerEnvironment)` to the environment variable list.

### Parameters ###

`value` specifies the inheritance behavior:

| Value       | Description                                              |
|-------------|----------------------------------------------------------|
| Default     | Use the toolset's default behavior (no explicit setting) |
| On          | Inherit parent environment variables                     |
| Off         | Do not inherit parent environment variables              |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

Set custom debug environment variables while preserving system environment:

```lua
filter "configurations:Debug"
  debugenvs { "MY_DEBUG_PATH=C:\\temp\\debug" }
  debugenvsinherit "On"
```

Use only custom environment variables, ignoring parent environment:

```lua
filter "configurations:Debug"
  debugenvs { "ISOLATED_ENV=1" }
  debugenvsinherit "Off"
```

### See Also ###

* [debugenvs](debugenvs.md)
* [debugenvsmerge](debugenvsmerge.md)
