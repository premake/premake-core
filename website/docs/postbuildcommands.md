Specifies shell commands to run after build is finished.

```lua
postbuildcommands { "commands" }
```

### Parameters ###

`commands` is one or more shell commands.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
postbuildcommands { "{COPYFILE} %[default.config] %[bin/project.config]" }
```

### See Also ###
 * [Tokens](Tokens.md)
 * [Custom Build Commands](Custom-Build-Commands.md)
 * [Tokens](Tokens.md)
 * [prebuildcommands](prebuildcommands.md)
 * [prelinkcommands](prelinkcommands.md)
