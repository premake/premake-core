Applies one or more "forced include" files to the project; these includes behave as it they had been injected into the first line of each source file in the project.

```lua
forceincludes  { "files" }
```

### Parameters ###

`files` specifies a list of files to be force included. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
forceincludes { "stdafx.h" }
```
