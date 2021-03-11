Enables Microsoft's Common Language Runtime for a project or configuration.

```lua
clr "value"
```

See [/clr (Common Language Runtime Compilation)](http://msdn.microsoft.com/en-us/library/k8d11d4s.aspx) in the Visual Studio documentation for more information.

### Parameters ###

`value` is one of the following:

| Value       | Description                                                            |
|-------------|------------------------------------------------------------------------|
| Off         | No CLR support                                                         |
| On          | Enable CLR support                                                     |
| Pure        | Enable pure mode MSIL. Equivalent to "On" for .NET projects.           |
| Safe        | Enable verifiable MSIL. Equivalent to "On" for .NET projects.          |
| Unsafe      | Enable unsafe operations. Equivalent to "On" for Managed C++ projects. |

CLR settings that do not make sense for the current configuration, such setting CLR support for a C# project to "Off", will be ignored.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.

### Examples ###

Set up a managed C++ project.

```lua
project "MyProject"
  kind "ConsoleApp"
  language "C++"
  clr "On"
```

Enable unsafe code in a C# project.

```lua
project "MyProject"
  kind "ConsoleApp"
  language "C#"
  clr "Unsafe"
```
