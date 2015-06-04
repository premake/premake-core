Premake Extension to support the [D](http://dlang.org) language

### Features ###

* Support actions: gmake, vs20xx (VisualD), monodevelop (Mono-D)
* Support all compilers; DMD, LDC, GDC
* Support combined and separate compilation

### Usage ###

Simply add:
```lua
language "D"
```
to your project definition and populate with .d files.

### APIs ###

* flags
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
* versionconstants
* versionlevel
* debugconstants
* debuglevel
* docdir
* docname
* headerdir
* headername

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
