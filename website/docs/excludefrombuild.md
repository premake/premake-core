Excludes a project from the build or a source file from a configuration.

```lua
excludefrombuild "On"
```

### Parameters ###

*value* specifies whether to exclude project or source file from build:

| Value       | Description                                  |
|-------------|----------------------------------------------|
| On          | Excludes a project from the build.           |
| Off         | Default behavior, includes project in build. |

### Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0-beta8 or later on Visual Studio.
