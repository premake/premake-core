Specifies specific warnings that should be interpreted as errors.

```lua
fatalwarnings { "warnings" }
```

### Parameters ###

`warnings` is a list of warnings to interpret as errors.

For Visual Studio, the MSC warning number should be used to specify the warning. On other compilers, the warning should be identified by name.

In addition, Premake provides two special values to turn on all compiler and linker warnings.

| Value   | Description                   |
-------------------------------------------
| Compile | Treat all compiler warnings as errors |
| Link    | Treat all linker warnings as errors   |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later. `Compile` and `Link` special values available since Premake 5.0-beta4 or later.

### See Also ###

* [enablewarnings](enablewarnings.md)
* [disablewarnings](disablewarnings.md)
