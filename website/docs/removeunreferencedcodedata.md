Sets the `RemoveUnreferencedCodeData` property for a configuration or all configurations within a project or workspace, adding or removing the `/Zc:inline[-]` build option.

[/Zc:inline (Remove unreferenced COMDAT)](https://docs.microsoft.com/en-us/cpp/build/reference/zc-inline-remove-unreferenced-comdat?view=msvc-160)

If this property is unset, it defaults to `true` in Visual Studio.

```lua
removeunreferencedcodedata ("value")
```

### Parameters ###

`value` one of:
* `on`  - Enables `RemoveUnreferencedCodeData`.
* `off` - Disables `RemoveUnreferencedCodeData`.

### Applies To ###

Workspaces and projects.

### Availability ###

Premake 5.0 alpha 16 or later.

### Examples ###

```lua
RemoveUnreferencedCodeData "Off"
```

