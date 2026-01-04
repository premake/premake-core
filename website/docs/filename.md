Sets the name of a generated workspace, project, or rules file. Use it in conjunction with [location](location.md) to completely control the generated file destination.

```lua
filename ("name")
```

By default, generated workspace, project, and rule files use their name as the name of the generated file. The `filename` function allows you to change this.


### Parameters ###

`name` is the desired file name for the generated workspace or project file. Do not specify the file extension, Premake would automatically add the correct extension for the file onto the end.


### Applies To ###

Workspace and project configurations and rule files.


### Examples ###

Change the workspace name to "Master".

```lua
workspace "MyWorkspace"
  filename "Master"
```

If you plan to build with multiple tools from the same source tree you might want to split up the project files by toolset. The _ACTION global variable contains the current toolset identifier, as specified on the command line.

```lua
workspace "MyWorkspace"
   filename "MyWorkspace_%{_ACTION or ''}"
```

### See Also ###

* [location](location.md)
