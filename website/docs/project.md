Creates a new project within the scope of a workspace.  After a project is invoked, any previous filter settings are cleared (i.e., reset).

```lua
project ("name")
```

Projects contain all of the settings necessary to build a single binary target, and are synonymous with a Visual Studio project. These settings include the list of source code files, the programming language used by those files, compiler flags, include directories, and which libraries to link against.

Every project belongs to a workspace.

### Parameters ###

`name` is the name for the project, which must be unique within the workspace which contains the project. If a project with the given name already exists, it is made active and returned.

If no name is given, the current project scope is returned, and also made active.

If "\*" is used, the containing workspace, which applies to all workspaces, is made active and nil is returned.

By default, the project name will be used as the file name of the generated project file; be careful with spaces and special characters. You can override this default with the [filename](filename.md) call.

### Availability ###

Premake 4.0 or later.

### Examples ###

Create a new project named "MyProject". Note that a workspace must exist to contain the project. The indentation is for readability and is optional.

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }

project "MyProject"
   kind "ConsoleApp"
   language "C++"
```

### See Also ###

* [group](group.md)
* [configuration](configuration.md)
* [location](location.md)
* [filename](filename.md)