inheritdependencies

```lua
inheritdependencies "value"
```

### Parameters ###

`value` one of:
* `On` - The project(s) will inherit library dependencies based on the parent project and project default settings. This is the default behavior.
* `Off` - The project(s) will not inherit any library dependencies. Only explicitly specified dependencies will be linked.

## Applies To ###

The `config` scope.

### Availability ###

Visual Studio 2019 and later.
Premake 5.0-beta2 or later.

### Examples ###

```lua
inheritdependencies "Off"
```

