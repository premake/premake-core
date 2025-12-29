Enable Windows Presentation Foundation (WPF) support for .NET projects.

```lua
wpf ("value")
```

If no value is set for a configuration, the toolset's default option will be used.

### Parameters ###

`value` specifies the desired wpf setting:

| Value      | Description                                       |
|------------|---------------------------------------------------|
| Default    | Use the default behavior (WPF not enabled)        |
| On         | Enable WPF support                                |
| Off        | Disable WPF support                               |

### Applies To ###

.NET project configurations.

### Availability ###

Premake 5.0.0-beta9 or later.

### Examples ###

Enable WPF support:

```lua
wpf "On"
```
