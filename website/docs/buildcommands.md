Specifies one or more shell commands to be executed to build a project or file.

```lua
buildcommands { "commands" }
```

### Parameters ###

`commands` specifies a list of one or more shell commands to be executed. The commands may use [tokens](Tokens.md).

### Applies To ###

Makefile projects and per-file custom build commands.

### Availability ###

Premake 5.0 or later.

### Examples ###

Use [per-file custom build commands](Custom-Build-Commands.md) to compile all Lua files in a project to C:

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

```

Use a [Makefile project](Makefile-Projects.md) to execute an external makefile.

```lua
workspace "Workspace"
   configurations { "Debug", "Release" }

project "MyProject"
   kind "Makefile"

   buildcommands {
      "make %{cfg.buildcfg}"
   }

   cleancommands {
      "make clean %{cfg.buildcfg}"
   }

```

## See Also ##

* [Custom Build Commands](Custom-Build-Commands.md)
* [Makefile Projects](Makefile-Projects.md)
* [buildinputs](buildinputs.md)
* [buildmessage](buildmessage.md)
* [buildoutputs](buildoutputs.md)
* [cleancommands](cleancommands.md)
* [rebuildcommands](rebuildcommands.md)
