Specifies specific warnings that should be interpreted as compile errors.

```lua
fatalwarnings { "warnings" }
```

### Parameters ###

`warnings` is a list of warnings to interpret as errors.

For Visual Studio, the MSC warning number should be used to specify the warning. On other compilers, the warning should be identified by name.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [enablewarnings](enablewarnings.md)
* [disablewarnings](disablewarnings.md)
