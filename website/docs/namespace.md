Sets the root namespace of a project.

```lua
namespace ("name")
```

By default, the root namespace for a project which match the target (assembly) name. This function allows you to override that default.

Currently, this is only applicable to Visual Studio C# projects.


### Parameters ###

`name` is the desired root namespace for the project.


### Applies To ###

Projects.


### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
project "MyProject"
   namespace "MyCompany.MyProject"
```
