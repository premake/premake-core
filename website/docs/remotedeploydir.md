Directory on the remote machine where the project will be deployed to.

```lua
remoteprojectdir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the project is deployed

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 3 or later, only applies to Visual Studio Linux projects.

### Examples ###

```lua
remoteprojectdir "$(RemoteProjectDir)"
```
