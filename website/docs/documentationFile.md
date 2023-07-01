---
title: documentationFile
---

Enable C# xmlDocumentationFile

# Usage (2) #
the xmlDocumentationFile is used for adding the [xml comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/) added to functions to a dll that has been packed inside a framework or other C# related dll that is refernced inside another project.

this feature sets the [documentationFIle](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/output#documentationfile) option inside csproj for each corresponding [configuration](https://premake.github.io/docs/configurations/)

## 1) Default ##

when you put documentationFile inside the project, the following filename/path will be generated:
```%{targetdir}/%{prj.name}.xml```
```lua
documentationFile ""
```

## 2) Custom Directory ##

when you put the following inside the project the following filename/path will be generated:
```bin\test\%{prj.name}.xml```

```lua
documentationFile "bin/test"
```
<b>the path is rellative to the projects [location](https://premake.github.io/docs/location/)

### Applies To ###

The `project` scope.

### Availability ###

Visual Studio 2005

## <b>NOTE !</b> ##
it is recommended to use the default option because visualStudio can only apply the xmlDocumentationFile when it is placed dirrectly next to the corresponding dll.

## See Also ##
more [info](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/#create-xml-documentation-output)
