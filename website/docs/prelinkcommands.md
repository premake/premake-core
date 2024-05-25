Specifies shell commands to run after the source files have been compiled, but before the link step (if unsupported by the action, it will be treated the same as [prebuildcommands](prebuildcommands.md)).

```lua
prelinkcommands { "commands" }
```

### Parameters ###

`commands` is one or more shell commands.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
prelinkcommands { "{COPYFILE} %[default.config] %[bin/project.config]" }
```

### See Also ###

 * [Tokens](Tokens.md)
 * [prelinkmessage](prelinkmessage.md)
 * [prebuildcommands](prebuildcommands.md)
 * [postbuildcommands](postbuildcommands.md)
 * [Tokens](Tokens.md)
