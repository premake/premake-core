Turn on/off debug symbol table generation.

```lua
symbols ("switch")
```

By default, the generated project files will use the compilers default settings for debug symbol generation. This might be on, or off, or entirely dependent on the configuration.

### Parameters ###

`switch` is an identifier for symbol information.

| Option      | Availability                |
|-------------|-----------------------------|
| `Default`   | Always available            |
| `Off`       | Always available            |
| `On`        | Always available            |
| `FastLink`  | Visual Studio 2015 or newer |
| `Full`      | Visual Studio 2017 or newer |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

This project generates debug symbol information for better debugging.

```lua
project "MyProject"
    symbols "On"
```

### See Also ###

 * [symbolspath](symbolspath.md)
 * [debugformat](debugformat.md)
