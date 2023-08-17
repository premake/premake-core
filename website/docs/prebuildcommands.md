Specifies shell commands to run before each build.

```lua
prebuildcommands { "commands" }
```

### Parameters ###

`commands` is one or more shell commands.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
prebuildcommands { "{COPYFILE} %[default.config] %[bin/project.config]" }
```

### See Also ###

 * [Tokens](Tokens.md)
 * [postbuildcommands](postbuildcommands.md)
 * [prelinkcommands](prelinkcommands.md)
