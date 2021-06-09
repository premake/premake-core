---
title: Makefile Projects
---

Makefile projects give you the ability to completely specify the build and clean commands for a project, and are useful when you would like to shell out to an existing Makefile or other command line process.

## Example Usage

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }

project "MyProject"
   kind "Makefile"

   buildcommands {
      "make %{cfg.buildcfg}"
   }

   rebuildcommands {
      "make %{cfg.buildcfg} rebuild"
   }

   cleancommands {
      "make clean %{cfg.buildcfg}"
   }

```

This closely follows Visual Studio's own Makefile project feature, but it should be easy to see how it would translate to makefiles.

Build rules follow the same configuration scoping as the rest of the Premake API. You can apply rules to a specific platform or build configuration, to specific files or all files, or to any combination.

If the outputs include any object files, they will be automatically added to the link step. Ideally, any source code files included in the outputs would be fed back into the build, but that is not the case currently.


## Current Issues

Makefile projects currently have a few shortcomings. Help fixing these issues, or any other gaps, would be most appreciated!

* The feature only works for Visual Studio currently.

* There is limited detection of paths in the build commands. Tokens that
  expand to absolute paths (most of them do, i.e. %{cfg.objdir}) are properly
  made project relative. Custom tokens, or paths hardcoded inline with the
  commands, must be specified relative to the generated project location.

(Did I miss anything?)


## See Also ##

* [Custom Build Commands](Custom-Build-Commands.md)
* [Custom Rules](Custom-Rules.md)
* [buildcommands](buildcommands.md)
* [buildoutputs](buildoutputs.md)
* [cleancommands](cleancommands.md)
* [rebuildcommands](rebuildcommands.md)
