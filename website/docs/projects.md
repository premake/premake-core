Add projects to a workspace.

```lua
projects({ 'name', ... })
```

### Parameters

`name` is the name of the project(s) to be added to the workspace. This call implicitly declares the project, which must then be configured using [`project()`](project.md) elsewhere in the script.

### Return Value

None.

### Availability

Premake 6.0 and later.

### See Also

- [`project()`](project.md)
- [`workspaces()`](workspaces.md)

### Examples

Declare a project, and then use it in multiple workspaces. The project may be declared before the workspaces, as shown, or after.

```lua
project('MyProject', function ()
	files({ '**.h', '**.cpp' })
end

workspace('Workspace1', function ()
	projects({ 'MyProject' })
end)

workspace('Workspace2', function ()
	projects({ 'MyProject' })
end)
```
