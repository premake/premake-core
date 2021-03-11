Specifies how a file or set of files should be treated during the compilation process. It is usually paired with a filter to select a file set. If no build action is specified for a file a default action will be used, based on the file's extension.

```lua
buildaction ("action")
```

### Parameters ###

For C/C++, `action` is the name of the MSBuild action as defined by the vcxproj format; eg: `ClCompile`, `FxCompile`, `None`, etc, and may refer to any such action available to MSBuild.

For C# projects, `buildaction` behaviour is special to support legacy implementation.
In C#, `action` is one of

| Action      | Description                                                           |
|-------------|-----------------------------------------------------------------------|
| Application | Mark the file as the application definition XAML for WPF.             |
| Compile     | Treat the file as source code; compile and link it.                   |
| Component   | Treat the source file as [a component][1], usually a visual control.  |
| Copy        | Copy the file to the target directory.                                |
| Embed       | Embed the file into the target binary as a resource.                  |
| Form        | Treat the source file as visual (Windows) form.                       |
| None        | Do nothing with this file.                                            |
| Resource    | Copy/embed the file with the project resources.                       |
| UserControl | Treat the source file as [visual user control][2].                    |

The descriptive actions such as **Component**, **Form*, and **UserControl** are only recognized by Visual Studio, and may be considered optional as Visual Studio will automatically deduce the types when it first examines the project. You only need to specify these actions to avoid unnecessary modifications to the project files on save.

### Applies To ###

File configurations.

### Availability ###

Build actions are currently supported for C/C++ and C# projects.

`Compile`, `Copy`, `Embed`, and `None` are available in Premake 4.4 or later. All actions are available in Premake 5.0 or later.

## Examples ##

Embed all PNG images files into the target binary.

```lua
filter "files:**.png"
   buildaction "Embed"
```

[1]: http://msdn.microsoft.com/en-us/library/ms228287(v=vs.90).aspx
[2]: http://msdn.microsoft.com/en-us/library/a6h7e207(v=vs.71).aspx
