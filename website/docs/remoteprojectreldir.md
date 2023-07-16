Specifies the subdirectory on the remote machine to deploy each project's source code to.

```lua
remoteprojectreldir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the source files of a single project will be copied to before compiling. A good default is to leave this empty, unless your includes somehow take this directory into account

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later, only applies to Linux projects.

### Examples ###

```lua
remoteprojectreldir "%{prj.name}"
```

