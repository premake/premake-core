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

* [flags](https://github.com/premake/premake-dlang/wiki/flags)
  * AllInstantiate 
  * CodeCoverage
  * Color
  * Documentation
  * GenerateHeader
  * GenerateJSON
  * GenerateMap
  * IgnorePragma
  * LowMem
  * Main
  * PerformSyntaxCheckOnly
  * Profile
  * ProfileGC
  * Quiet
  * RetainPaths
  * ShowCommandLine
  * ShowDependencies
  * ShowGC
  * ShowTLS
  * StackFrame
  * StackStomp
  * SymbolsLikeC
  * UnitTest
  * UseLDC
  * Verbose
* boundscheck ("type") [Off, SafeOnly, On]
* compilationmodel ("model") [ Project, Package, File ]
* checkaction
* computetargets
* [debugconstants](https://github.com/premake/premake-dlang/wiki/debugconstants)
* [debuglevel](https://github.com/premake/premake-dlang/wiki/debuglevel)
* dependenciesfile ("filename")
* deprecatedfeatures ("feature") [ Error, Info, Allow ]
* [docdir](https://github.com/premake/premake-dlang/wiki/docdir)
* [docname](https://github.com/premake/premake-dlang/wiki/docname)
* [headerdir](https://github.com/premake/premake-dlang/wiki/headerdir)
* [headername](https://github.com/premake/premake-dlang/wiki/headername)
* importdirs { "paths" }
* [inlining](https://github.com/premake/premake-core/wiki/inlining)
* jsonfile ("filename")
* importdirs
* [optimize](https://github.com/premake/premake-core/wiki/optimize)
* preview
* revert
* runtime ("type") [ Debug, Release ]
* staticruntime ("state") [ on, off ]
* stringimportdirs { "paths" }
* transition
* [versionconstants](https://github.com/premake/premake-dlang/wiki/versionconstants)
* [versionlevel](https://github.com/premake/premake-dlang/wiki/versionlevel)

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
