Passes arguments directly to the image tool command line without translation.

```lua
imageoptions { "options" }
```

If a project includes multiple calls to `imageoptions` the lists are concatenated, in the order in which they appear in the script.

Image options are currently only supported for Xbox 360 targets.

### Parameters ###

`options` is a list of image tools flags and options.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [deploymentoptions](deploymentoptions.md)
* [imagepath](imagepath.md)
