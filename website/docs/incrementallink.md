Controls whether incremental linking is enabled for a configuration.

```lua
incrementallink ("value")
```

Incremental linking can improve iteration times during development by only relinking the portions of the binary that have changed. However, it may prevent some optimizations and is typically disabled for release builds.

### Parameters ###

*value* specifies the incremental linking setting:

| Value   | Description                                                  |
|---------|--------------------------------------------------------------|
| Default | Use the default incremental linking behavior. Incremental linking is enabled for debug builds and disabled for optimized builds, static libraries, and when link-time optimization is enabled. |
| On      | Force incremental linking to be enabled.                     |
| Off     | Force incremental linking to be disabled.                    |

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0-beta8 or later.

### Examples ###

Force incremental linking off for all configurations:

```lua
filter "configurations:*"
   incrementallink "Off"
```

Enable incremental linking even in release builds:

```lua
filter "configurations:Release"
   incrementallink "On"
```

### See Also ###

* [linktimeoptimization](linktimeoptimization.md)
* [optimize](optimize.md)
