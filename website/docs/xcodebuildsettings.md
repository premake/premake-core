xcodebuildsettings

```lua
xcodebuildsettings { ["key"] = "value" }
```

### Parameters ###

key/value pairs to apply to `buildSettings` blocks of the generated `pbxproj`

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
xcodebuildsettings { ["MY_KEY"] = "MY_VALUE" }
```
will generate:

    buildSettings = {
        ...
        MY_KEY = MY_VALUE;
        ...
    }
