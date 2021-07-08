Declares one or more workspaces.

```lua
workspaces({ 'name', ... })
```

This isn't a function you'd normally call directly; use [`workspace()`](workspace.md) instead to declare the workspace and configure its settings in one step.

### Parameters

`name` is the name of the workspaces(s) to be declared. This call implicitly declares the workspace, which must then be configured using [`workspace()`](workspace.md) elsewhere in the script.

### Return Value

None.

### Availability

Premake 6.0 and later.

### See Also

- [`workspace()`](workspace.md)
- [`projects()`](projects.md)

### Examples

```lua
workspaces({ 'Workspace1', 'Workspace2' })

workspace('Workspace1', function ()
	configurations({ 'Debug', 'Release' })
end)

workspace('Workspace2', function ()
	configurations({ 'Debug', 'Release' })
end)
```
