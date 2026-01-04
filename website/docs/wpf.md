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

project configurations.

### Availability ###

Premake 5.0.0-beta8 or later for Visual Studio .NET projects.

### Examples ###

Enable WPF support:

```lua
wpf "On"
```
