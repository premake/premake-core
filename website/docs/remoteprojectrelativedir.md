Specifies the subdirectory on the remote machine to copy each project's source code to.

```lua
remoteprojectrelativedir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the source files of a single project will be copied to before compiling, relative to the root path

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later, only applies to Visual Studio Linux projects.

### Examples ###

```lua
remoteprojectrelativedir "%{prj.name}"
```
