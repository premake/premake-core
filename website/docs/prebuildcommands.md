Specifies shell commands to run before each build.

```lua
prebuildcommands { "commands" }
```

### Parameters ###

`commands` is one or more shell commands. These commands will be passed to the shell exactly as entered, including path separators and the like.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

### Examples ###

```lua
configuration "windows"
   prebuildcommands { "copy default.config bin\\project.config" }

configuration "not windows"
   prebuildcommands { "cp default.config bin/project.config" }
```

### See Also ###

 * [postbuildcommands](postbuildcommands.md)
 * [prelinkcommands](prelinkcommands.md)
