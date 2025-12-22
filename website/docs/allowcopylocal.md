Specifies whether or not to allow for copy local of assemblies.

```lua
allowcopylocal "value"
```

### Parameters ###

`value` specifies the desired copy mode:

| Value       | Description                                                       |
|-------------|-------------------------------------------------------------------|
| Default     | Perform the default copy local mechanism for the exporter.        |
| Off         | Do not copy local assemblies to the output directory.             |
| On          | Allow the local assemblies to be copied to the output directory.  |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0-beta8 or later for Visual Studio C# Projects.

### See Also ###

* [copylocal](copylocal.md)
