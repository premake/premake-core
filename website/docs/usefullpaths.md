Turn on/off full paths usage in diagnostics

```lua
usefullpaths ("value")
```

By default, the generated project files will use the compilers default settings, which is in most cases "On" for debug and "Off" for release.
In Visual Studio, this overrides the /FC flag which is forced on when using debug builds.

### Parameters ###

`value` specifies relative path usage.

| Option      | Description                |
|-------------|-----------------------------|
| `Off`       | Use relative paths in diagnostics            |
| `On`        | Use absolute (full) paths in diagnostics           |

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0-beta1 or later.

### Examples ###

```lua
project "MyProject"
    usefullpaths "On" -- Uses full paths in diagnostics
```

