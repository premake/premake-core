staticruntime

```lua
staticruntime "value"
```

### Parameters ###

| Value      | Visual Studio                                 | XCode     | gmake/gmake2 |
|------------|-----------------------------------------------|-----------|-----------|
| `Default`  | Does not set a value for `<RuntimeLibrary>`   | No Effect | No Effect |
| `On`       | Sets `<RuntimeLibrary>` to "MultiThreaded"    | No Effect | No Effect |
| `Off`      | Sets `<RuntimeLibrary>` to "MultiThreadedDLL" | No Effect | No Effect |

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
staticruntime "on"
```

