Directory on the remote machine where the project will be deployed to.

```lua
remoteprojectdir ("path")
```

### Parameters ###

`path` specifies the directory on the remote machine where the project is deployed

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later, only applies to Visual Studio Linux projects.

### Examples ###

```lua
remoteprojectdir "$(RemoteProjectDir)"
```
