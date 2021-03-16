Specifies one or more file extensions to find and remove when cleaning the project.

```lua
cleanextensions { ".ext1", ".ext2" }
```

### Parameters ###

A list of dot-prefixed file extensions to be cleaned.

### Applies To ###

Projects.

### Availability ###

Premake 5.0 or later. This function is currently implemented only for Visual Studio 201x.

### Examples ###

Remove .zip files from the output directory when cleaning.

```lua
cleanextensions { ".zip" }
```
