Specifies the application icon resource.

```lua
icon ("name")
```

Currently, this is only used by Visual Studio C# projects.

### Parameters ###

`name` is the resource name of the icon.

### Applies To ###

Projects.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
project "MyProject"
   icon "MyProject.ico"
```
