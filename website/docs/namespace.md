Sets the root namespace of a project.

```lua
namespace ("name")
```

By default, the root namespace for a project which match the target (assembly) name. This function allows you to override that default.


### Parameters ###

`name` is the desired root namespace for the project.


### Applies To ###

Projects.


### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio C# Projects.


### Examples ###

```lua
project "MyProject"
   namespace "MyCompany.MyProject"
```
