Applies one or more "forced using" files to the project; these includes behave as it they had been injected into the first line of each source file in the project.

```lua
forceusings  { "files" }
```

### Parameters ###

`files` specifies a list of files to be force included. Paths should be specified relative to the currently running script file.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

```lua
forceusings { "stdafx.h" }
```
