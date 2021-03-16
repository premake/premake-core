Specifies one or more shell commands to be executed to clean a [Makefile project](Makefile-Projects.md).

```lua
cleancommands { "commands" }
```

### Parameters ###

`commands` specifies a list of one or more shell commands to be executed. The commands may use tokens.

### Applies To ###

[Makefile projects](Makefile-Projects.md)

### Availability ###

Premake 5.0 or later.

## Examples ##

Use a [Makefile project](Makefile-Projects.md) to execute an external makefile.

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

## See Also ##

* [Custom Build Commands](Custom-Build-Commands.md)
* [Makefile Projects](Makefile-Projects.md)
* [buildcommands](buildcommands.md)
* [buildmessage](buildmessage.md)
* [buildoutputs](buildoutputs.md)
* [rebuildcommands](rebuildcommands.md)
