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

### APIs ###

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
