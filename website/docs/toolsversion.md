Selects the tools version which is used to build a project.

```lua
toolsversion ("identifier")
```

If no version is specified for a configuration, the build tool will define the a default version.

### Parameters ###

`identifier` is a string identifier for the toolset version.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 and later. Versions are currently only implemented for Visual Studio 2017+.

### Examples ###

Specify tool version 14.27.29110 of the toolset.

```lua
toolsversion "14.27.29110"
```