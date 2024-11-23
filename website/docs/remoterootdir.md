Specifies the base directory on the remote machine to deploy the source code to before compiling.

```lua
remoterootdir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the source files will be copied to before compiling

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 3 or later, only applies to Visual Studio Linux projects.

### Examples ###

```lua
remoterootdir "~/projects/%{prj.name}"
```
