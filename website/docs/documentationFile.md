---
title: documentationFile
---

Enable C# xmlDocumentationFile

# Usage (2) #
the DocumentationFile is used for adding the [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) added to functions/ variables, to a dll that has been packed inside a framework or other C# related.
this can then be referenced inside another project by placing it next to the corresponding dll.

this feature sets the [DocumentationFile](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option inside csproj for each corresponding [configuration](https://premake.github.io/docs/configurations/)

## 1) Default ##

when you put documentationfile inside the project, the following filename/path will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationfile ""
```

## 2) Custom Directory ##

when you put the following inside the project the following filename/path will be generated:
```bin\test\%{prj.name}.xml```

```lua
documentationfile "bin/test"
```
<b>the path is rellative to the projects [location](https://premake.github.io/docs/location/)

### Applies To ###

The `project` scope.

### Availability ###

Visual Studio 2005

## <b>NOTE !</b> ##
it is recommended to use the default option because Visual Studio can only apply the DocumentationFile when it is placed dirrectly next to the corresponding dll.

## See Also ##
more [info](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/#create-xml-documentation-output)
