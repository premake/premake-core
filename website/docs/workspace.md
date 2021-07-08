Declare a new workspace.

```lua
workspace('name', function ()
   -- settings
end)
```

Workspaces are the top-level objects in a Premake build script, and are synonymous with a Visual Studio solution. Each workspace contains one or more projects, which in turn contain the settings to generate a single binary target.

### Parameters

`name` is a unique name for the workspace. If a workspace with the given name already exists, any new settings provided will be merged into the previous declared instance. By default, this value will also become the default file name when the workspace is exported; override it with [`filename()`](filename.md).

`function` is a callback which specifies the build settings for the workspace, optionally including the projects which make up the workspace as well.

### Return Value

None.

### Availability

Premake 6.0 and later.

### See Also

- [`project()`](project.md)
- [`location()`](location.md)
- [`filename()`](filename.md)
- [`workspaces()`](workspaces.md)

### Examples

Declare a new workspace "MyWorkspace", and set up some build configurations and a child project.

```lua
workspace('MyWorkspace', function ()
	configurations({ 'Debug', 'Release' })

	project('MyProject', function ()
		files({ '**.h', '**.cpp' })
	end)
end)
```
