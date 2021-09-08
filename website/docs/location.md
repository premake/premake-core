Sets the destination directory for a generated workspace or project file.

```lua
location ("path")
```

By default, workspace and project files are generated into the same directory as the script that defines them. The `location` function allows you to change this location.

Note that unlike other values, `location` does not automatically propagate to the contained projects. Projects will use their default location unless explicitly overridden.

### Parameters ###

`path` is the directory where the generated files should be stored, specified relative to the currently executing script file.

### Applies To ###

Workspaces and projects.

### Availability ###

Premake 4.0 or later.

### Examples ###

Set the destination directory for a workspace. Setting the location for a project works the same way.

```lua
workspace "MyWorkspace"
  location "../build"
```

If you plan to build with multiple tools from the same source tree you might want to split up the project files by toolset. The [_ACTION](premake_ACTION.md) global variable contains the current toolset identifier, as specified on the command line. Note that Lua syntax requires parenthesis around the function parameters in this case.

```lua
location ("../build/" .. _ACTION)
```
