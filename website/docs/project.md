Declare a new project.

```lua
project('name', function ()
   -- settings
end)
```

Projects contain all of the settings necessary to build a single binary target, and are synonymous with a Visual Studio project. These settings include the list of source code files, the tool(s) required to build the binary, compiler flags, include directories, and libraries to be linked.

Each project must be contained by a [workspace](workspace.md).

### Parameters

`name` is a unique name for the project, within the scope of the workspace which contains it. If the workspace already contains a project with the given name, any the provided settings will be merged into the previously declared instance. By default, this value will also become the default file name when the project is exported; override it with [`filename()`](filename.md).

`function` is a callback which specifies the build settings for the project.

### Return Value

None.

### Availability

Premake 6.0 and later.

### See Also

- [`workspace()`](workspace.md)
- [`projects()`](projects.md)
- [`location()`](location.md)
- [`filename()`](filename.md)

### Examples

Declare a new project "MyProject", contained by workspace "MyWorkspace".

```lua
workspace('MyWorkspace', function ()
	configurations({ 'Debug', 'Release' })

	project('MyProject', function ()
		files({ '**.h', '**.cpp' })
	end)
end)
```

Projects may also be declared outside of any scope, and then connected to one or more workspaces using [`projects()`](projects.md).

```lua
workspace('Workspace1', function ()
	projects({ 'MyProject' })
end)

workspace('Workspace2', function ()
	projects({ 'MyProject' })
end)

project('MyProject', function ()
	files({ '**.h', '**.cpp' })
end)
```

When reusing projects across multiple workspaces care must be taken to either assign each project a unique [location](location.md) or [filename](filename.md); or to ensure that the settings contained by the project do not vary by workspace. If two workspaces declare different settings for the same project, and place the project at the same location, the last one exported will "win".
