Specifies shell commands to run after the source files have been compiled, but before the link step.

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
prelinkcommands { "{COPY} %[default.config] %[bin/project.config]" }
```

### See Also ###

 * [Tokens](Tokens.md)
 * [prebuildcommands](prebuildcommands.md)
 * [postbuildcommands](postbuildcommands.md)
