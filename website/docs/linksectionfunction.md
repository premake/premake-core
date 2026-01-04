Emit each function item in a separate section. This help linker optimizations to remove unused data.

```lua
linksectionfunction ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Emit individual function items in separate sections. |
| Off   | Do not enable forced separate sections for function items. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta4 or later for Visual Studio 2022 and later, only applies to Visual Studio Android projects.
