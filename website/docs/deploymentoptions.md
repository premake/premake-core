Passes arguments directly to the deployment tool command line without translation.

```lua
deploymentoptions { "options" }
```

If a project includes multiple calls to `deploymentoptions` the lists are concatenated, in the order in which they appear in the script.

Deployment options are currently only supported for Xbox 360 targets.

### Parameters ###

`options` is a list of deployment tools flags and options.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.4 or later.

