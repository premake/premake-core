Specifies whether or not Visual Studio should perform Fast Up To Date Checks before invoking MSBuild.

```lua
fastuptodate ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Enable VS fast up to date checks |
| Off   | Disable VS fast up to date checks |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta1 or later for Visual Studio 2010+.

### Examples ###

```lua
fastuptodate "On"
```

