---
title: Custom Build Commads
---

There are a few different ways that you can add custom commands to your Premake-generated builds: *pre- and post-build stages*, *custom build commands*, and *custom rules*.

You can also use [Makefile projects](Makefile-Projects.md) to execute external shell scripts or makefiles, rather than use the normal build system.

## Pre- and Post-Build Stages

These are the simplest to setup and use: pass one or more command lines to the [`prebuildcommands`](prebuildcommands.md), [`prelinkcommands`](prelinkcommands.md), or [`postbuildcommands`](postbuildcommands.md) functions. You can use [Tokens](Tokens.md) to create generic commands that will work across platforms and configurations.


```lua
-- copy a file from the objects directory to the target directory
postbuildcommands {
  "{COPY} %{cfg.objdir}/output.map %{cfg.targetdir}"
}
```

## Custom Build Commands

*As of this writing, the custom build commands feature is still incomplete; see the list of limitations below.*

Custom build commands provide the ability to compile or process new types of files, other than the C/C++ or C# files Premake supports out of the box. You can compile a Cg shader program, or process an image.

Here is an example which compiles all Lua files in a project to C:

```lua
filter 'files:**.lua'
   -- A message to display while this build step is running (optional)
   buildmessage 'Compiling %{file.relpath}'

   -- One or more commands to run (required)
   buildcommands {
      'luac -o "%{cfg.objdir}/%{file.basename}.out" "%{file.relpath}"'
   }

   -- One or more outputs resulting from the build (required)
   buildoutputs { '%{cfg.objdir}/%{file.basename}.c' }

   -- One or more additional dependencies for this build command (optional)
   buildinputs { 'path/to/file1.ext', 'path/to/file2.ext' }

```

The basic syntax follows Visual Studio's model, but it should be easy to see how it would translate to makefiles.

Build rules follow the same configuration scoping as the rest of the Premake API. You can apply rules to a specific platform or build configuration, to specific files or all files, or to any combination. And you can use [Tokens](Tokens.md) to create generic commands that will work across platforms and configurations.

If the outputs include any object files, they will be automatically added to the link step.
Any source code files included in the outputs might be fed back into the build with [compilebuildoutputs](compilebuildoutputs.md).


Custom build commands currently have a few shortcomings. Help fixing these issues, or any other gaps, would be most appreciated!

* There is limited detection of paths in the build commands. Tokens that
  expand to absolute paths (most of them do, i.e. %{cfg.objdir}) are properly
  made project relative. Custom tokens, or paths hardcoded inline with the
  commands, must be specified relative to the generated project location.

* Commands that output C/C++ source files are not fed into the build
  process yet (but commands that output object files are fed to the
  linker).

* The generated makefile rule only takes the first output into account
  for dependency checking.


## Custom Rules ##

The [custom rules feature](Custom-Rules.md) is similar to custom build commands. It allows you describe how to build a particular kind of file, but in a more generic way, and with variables that can be set in your project script. [Learn more about custom rules here](Custom-Rules.md).
