---
title: documentation file
---

Enables C# xmlDocumentationFile

# Usage (2) #
The Documentation File is used for adding the [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) added to functions/ variables, to a dll that has been packed inside a framework or other C# related project.
This can then be referenced inside another project by placing it next to the corresponding dll.

This feature sets the [Documentation File](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option inside csproj for each corresponding [configuration](https://premake.github.io/docs/configurations/)

## 1) Default ##

When you put **documentationfile** inside the project configuration, the following filename/path will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationfile ""
```

## 2) Custom Directory ##

When you put the following inside the project configuration the following filename/path will be generated:
```bin\test\%{prj.name}.xml```

```lua
documentationfile "bin/test"
```
<b>The path is relative to the project [location](https://premake.github.io/docs/location/)

### Applies To ###

The `project` scope.

### Availability ###

Visual Studio 2005

## <b>NOTE !</b> ##
It is recommended to use the default option because Visual Studio can only apply the Documentation File when it is placed directly next to the corresponding DLL.

## See Also ##
More [info](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/#create-xml-documentation-output)
