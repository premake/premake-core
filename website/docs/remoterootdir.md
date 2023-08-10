Specifies the base directory on the remote machine to deploy to.

```lua
remoterootdir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the source files will be copied to before compiling

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later, only applies to Linux projects.

### Examples ###

```lua
remoterootdir "projects/directory"
```

