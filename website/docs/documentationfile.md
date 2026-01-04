Enables C# xmlDocumentationFile

```lua
documentationfile ("targetdir")
```

The `xmlDocumentationFile` option is used to include [XML comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) in a DLL that has been included in a .NET framework or another C# project. These XML comments can then be referenced by other projects when placed alongside the corresponding SharedLib.

This feature sets the [documentationfile](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option in a C# project's .csproj file for each respective [configuration](https://premake.github.io/docs/configurations/)

### Parameters ###
`targetdir` is the directory where the documentation file should be placed after building the project using visual studio.

### Examples ###

When you set documentationFile to true, the following filepath will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationfile(true)
```
If you specify a custom target directory like this:
```lua
documentationfile("%{prj.location}/bin/test")
```
the following filepath will be generated:
```bin\test\%{prj.name}.xml```

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later for Visual Studio.

### Warning ###
It's recommended to use `documentationfile(true)` because Visual Studio's intellisense will not detect the XML file if its name is not the same as the SharedLib.

### See Also ###
For more information on XML documentation in C#, refer to:
1) [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/)
2) [documentation file](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile)
3) [configuration](https://premake.github.io/docs/configurations/)
