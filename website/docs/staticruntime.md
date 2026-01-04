Specifies if the static runtime should be used.

```lua
staticruntime ("value")
```

### Parameters ###

| Value      | Visual Studio                                 | XCode     | gmake     |
|------------|-----------------------------------------------|-----------|-----------|
| `Default`  | Does not set a value for `<RuntimeLibrary>`   | No Effect | No Effect |
| `On`       | Sets `<RuntimeLibrary>` to "MultiThreaded"    | No Effect | No Effect |
| `Off`      | Sets `<RuntimeLibrary>` to "MultiThreadedDLL" | No Effect | No Effect |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
staticruntime "on"
```

