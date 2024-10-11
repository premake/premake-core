Sets the base directory for a configuration, from with other paths contained by the configuration will be made relative at export time.

This base directory is used when expanding path tokens encountered in non-path values. Such values will be made relative to this value so the resulting projects will only contain relative paths.

```lua
basedir ("value")
```

You do not normally need to set this value, as it is filled in automatically with the current working directory at the time the configuration block is created by the script.

### Parameters ###

`value` is an absolute path, from which other paths contained by the configuration should be made relative.

### Applies To ###

Any configuration.

### Availability ###

Premake 4.4 or later.
