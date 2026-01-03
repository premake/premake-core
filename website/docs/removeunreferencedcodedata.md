Sets the `RemoveUnreferencedCodeData` property for a configuration or all configurations within a project or workspace, adding or removing the `/Zc:inline[-]` build option.

[/Zc:inline (Remove unreferenced COMDAT)](https://docs.microsoft.com/en-us/cpp/build/reference/zc-inline-remove-unreferenced-comdat?view=msvc-160)

If this property is unset, it defaults to `true` in Visual Studio.

```lua
removeunreferencedcodedata ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Enable removing of unreferenced COMDATs. |
| Off   | Disable removing of unreferenced COMDATs. |

### Applies To ###

Workspace and project configurations.

### Availability ###

Premake 5.0.0-alpha16 or later in Visual Studio 2010+.

### Examples ###

```lua
RemoveUnreferencedCodeData "Off"
```

