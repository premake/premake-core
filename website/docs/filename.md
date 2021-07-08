Set the base file name for an exported object, such as a workspace or project. Use in conjunction with [`filename()`](filename.md) to completely control the generated file destination.


```lua
filename('name')
```

### Parameters

`name` is the desired file name for the generated workspace or project file. Do not specify the file extension; Premake would automatically add the correct extension for the type of project file being created, eg. `.vcxproj` for a Visual Studio C++ project.

### Return Value

None.

### Availability

Premake 5.0 and later.

### Supported Actions

- [Visual Studio](/actions/vstudio.md)

### See Also

- [`location()`](location.md)

### Examples

By default, the name of the object being exported (in this case a workspace) will be used as the export file name. Override the default value of "MyWorkspace" with "ProjectX".

```lua
workspace('MyWorkspace', function ()
	filename('ProjectX')
end)
```
