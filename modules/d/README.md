Premake Extension to support the [D](http://dlang.org) language

### Features ###

* Support actions: gmake, vs20xx (VisualD)
* Support all compilers; DMD, LDC, GDC
* Support combined and separate compilation

### Usage ###

Simply add:
```lua
language "D"
```
to your project definition and populate with .d files.  
C and C++ projects that include .d files will also support some of the API below. Any API tagged with (D/C/C++) works in D and C/C++ projects. Any API tagged with (C/C++) only works for .d files in C/C++ projects.

### APIs ###
## D ##
* [flags](https://github.com/premake/premake-dlang/wiki/flags)
  * CodeCoverage
  * Deprecated
  * Documentation
  * GenerateHeader
  * GenerateJSON
  * GenerateMap
  * NoBoundsCheck
  * Profile
  * Quiet
  * RetainPaths
  * SeparateCompilation
  * SymbolsLikeC
  * UnitTest
  * Verbose
* [versionconstants](https://github.com/premake/premake-dlang/wiki/versionconstants)
* [versionlevel](https://github.com/premake/premake-dlang/wiki/versionlevel)
* [debugconstants](https://github.com/premake/premake-dlang/wiki/debugconstants)
* [debuglevel](https://github.com/premake/premake-dlang/wiki/debuglevel)
* [docdir](https://github.com/premake/premake-dlang/wiki/docdir)
* [docname](https://github.com/premake/premake-dlang/wiki/docname)
* [headerdir](https://github.com/premake/premake-dlang/wiki/headerdir)
* [headername](https://github.com/premake/premake-dlang/wiki/headername)

## C/C++ ##

* [flags](https://github.com/premake/premake-dlang/wiki/flags)
  * CodeCoverage
  * UnitTest 
  * Verbose 
  * Profile
  * ProfileGC 
  * StackFrame 
  * StackStomp 
  * AllTemplateInst 
  * BetterC 
  * Main 
  * ShowCommandLine 
  * ShowTLS 
  * ShowGC 
  * IgnorePragma 
  * ShowDependencies
* [versionconstants](https://github.com/premake/premake-dlang/wiki/versionconstants)
* [debugconstants](https://github.com/premake/premake-dlang/wiki/debugconstants)
* [docdir](https://github.com/premake/premake-dlang/wiki/docdir)
* [docname](https://github.com/premake/premake-dlang/wiki/docname)
* [headerdir](https://github.com/premake/premake-dlang/wiki/headerdir)
* [headername](https://github.com/premake/premake-dlang/wiki/headername)
* dependenciesfile ("filename")
* jsonfile  ("filename")
* importpaths { "paths" }
* stringimportpaths { "paths" }
* compilationmodel ("model") [ Project, Package, File ]
* runtime ("type") [ Debug, Release ]
* staticruntime ("state") [ on, off ]
* [optimize](https://github.com/premake/premake-core/wiki/optimize)
* [inlining](https://github.com/premake/premake-core/wiki/inlining)
* boundscheck ("type") [Off, SafeOnly, On]
* deprecatedfeatures ("feature") [ Error, Info, Allow ]
		
### Example ###

The contents of your premake5.lua file would be:

```lua
solution "MySolution"
    configurations { "release", "debug" }

    project "MyDProject"
        kind "ConsoleApp"
        language "D"
        files { "src/main.d", "src/extra.d" }
```
