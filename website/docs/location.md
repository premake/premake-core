Sets the destination directory for an exported object, such as a workspace or project. Use in conjunction with [`filename()`](filename.md) to completely control the exported file destination.

```lua
location('path')
```

By default, exported files are generated into the same directory as the script that defines the workspace, project, etc. being exported. The `location()` function allows you to change this location.

### Parameters

`path` is the directory where the exported files should be stored, specified relative to the currently executing script file.

### Return Value

None.

### Availability

Premake 5.0 and later.

### Supported Actions

- [Visual Studio](/actions/vstudio.md)

### See Also

- [`filename()`](filename.md)

### Examples

Set the destination directory for a workspace. Setting the location for a project works the same way.

```lua
workspace('MyWorkspace', function ()
  location('../build')
end)
```
