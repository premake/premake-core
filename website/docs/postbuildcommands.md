Specifies shell commands to run after build is finished.

```lua
postbuildcommands { "commands" }
```

### Parameters ###

`commands` is one or more shell commands. These commands will be passed to the shell exactly as entered, including path separators and the like.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
filter { "system:windows" }
   postbuildcommands { "copy default.config bin\\project.config" }

filter { "not system:windows" }
   postbuildcommands { "cp default.config bin/project.config" }
```

### See Also ###
 * [Custom Build Commands](Custom-Build-Commands.md)
 * [Tokens](Tokens.md)
 * [prebuildcommands](prebuildcommands.md)
 * [prelinkcommands](prelinkcommands.md)
