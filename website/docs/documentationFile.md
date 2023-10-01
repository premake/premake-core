Enables C# xmlDocumentationFile

The documentation file is used for adding [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) to a dll that has been packed inside a framework or other C# related project.
This can then be referenced inside other projects by placing it next to the corresponding dll.

This feature sets the [documentationfile](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option inside csproj for each corresponding [configuration](https://premake.github.io/docs/configurations/)

```lua
documentationfile "targetdir"
```
### Parameters ###
`targetdir` is the directory where the documentation file should be placed after building the project using visual studio.

### Examples ###

When you put **documentationfile** inside the project configuration, the following filename/path will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationfile ""
```

When you put the following inside the project configuration, the following filename/path will be generated:
```bin\test\%{prj.name}.xml```

```lua
documentationfile "%{prj.location}/bin/test"
```
### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

Visual studio 2005 C# is the only toolset currently supported.

### Warning ###
default option is recommendes because visual studio cannot detect the xml file if the name is the same as the dll.
### See Also ###
More [info](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/#create-xml-documentation-output)
[xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/)
[documentation file](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile)
[configuration](https://premake.github.io/docs/configurations/)
