Creates a new workspace.

```lua
workspace ("name")
```

Workspaces are the top-level objects in a Premake build script, and are synonymous with a Visual Studio solution. Each workspace contains one or more projects, which in turn contain the settings to generate a single binary target.

### Parameters ###

`name` is a unique name for the workspace. If a workspace with the given name already exists, it is made active and returned.

If no name is given, the current workspace scope is returned, and also made active.

If "\*" is used, the "root" configuration scope, which applies to all workspaces, is selected and nil is returned.

By default, the project name will be used as the file name of the generated project file; be careful with spaces and special characters. You can override this default with the [filename](filename.md) call.

### Availability ###

Premake 4.0 or later.

### Examples ###

Create a new workspace named "MyWorkspace", with debug and release build configurations.
```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
```

### See Also ###

* [project](project.md)
* [group](group.md)
* [configuration](configuration.md)
* [location](location.md)
* [filename](filename.md)
