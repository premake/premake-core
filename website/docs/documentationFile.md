Enables C# xmlDocumentationFile

The Documentation File is used for adding the [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) added to functions/ variables, to a dll that has been packed inside a framework or other C# related project.
This can then be referenced inside another project by placing it next to the corresponding dll.

This feature sets the [Documentation File](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option inside csproj for each corresponding [configuration](https://premake.github.io/docs/configurations/)

```lua
documentationfile "targetdir"
```
### Parameters ###
`targetdir` is the directory where the Documentation File should be placed after building the project using Visual Studio.

### Examples ###

When you put **documentationfile** inside the project configuration, the following filename/path will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationfile ""
```

When you put the following inside the project configuration the following filename/path will be generated:
```bin\test\%{prj.name}.xml```

```lua
documentationfile "%{prj.location}/bin/test"
```
### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

Visual Studio 2005 C# is the only toolset currently supported.

### Warning ###
It is recommended to use the default option because Visual Studio can only apply the Documentation File when it is placed directly next to the corresponding DLL.

### See Also ###
More [info](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/#create-xml-documentation-output)
[xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/)
[Documentation File](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile)
[configuration](https://premake.github.io/docs/configurations/)
