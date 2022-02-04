Enables the `Scan Sources for Module Dependencies` option for Visual Studio projects.

```lua
scanformoduledependencies "value"
```

### Parameters ###

`value` one of:
* `on`, `yes`, `true` - Sets the option to `Yes`.
* `off`, `no`, `false` - Sets the option to `No`.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0-beta2 or later. Only available for Visual Studio 2019 16.9.x and later.

## Examples ##

```lua
scanformoduledependencies "true"
```