Specify the startup project for a workspace.

```lua
startproject ("name")
```

Startup projects are currently only supported by Visual Studio.

### Parameters ###

`name` is the name of the startup project. This should match the name provided in the call to project(), where the project is defined.

### Applies To ###

Workspace configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

```lua
workspace "MyWorkspace"
    configurations { "Debug", "Release" }
    startproject "MyProject2"

project "MyProject1"
    -- define project 1 here

project "MyProject2"
    -- define project 2 here
```
