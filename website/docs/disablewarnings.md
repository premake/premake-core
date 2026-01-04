Disables specific compiler warnings.

```lua
disablewarnings { "warnings" }
```

### Parameters ###

`warnings` is a list of warnings to disable.

For Visual Studio, the MSC warning number should be used to specify the warning. On other compilers, the warning should be identified by name.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

Xcode project generation does not yet support `disablewarnings`. As a workaround, you can use [[xcodebuildsettings]] like this:

```lua
xcodebuildsettings {
    WARNING_CFLAGS = "-Wall -Wextra " ..
        "-Wno-missing-field-initializers " ..
        "-Wno-unknown-pragmas " ..
        "-Wno-unused-parameter " ..
        "-Wno-unused-local-typedef " ..
        "-Wno-missing-braces " ..
        "-Wno-microsoft-anon-tag "
}
```

### Examples ###

Disable the GCC warning about using old-style C casts (`-Wno-old-style-cast` command line argument):

```lua
filter "options:cc=gcc"
  disablewarnings "old-style-cast"
```

### See Also ###

* [enablewarnings](enablewarnings.md)
* [fatalwarnings](fatalwarnings.md)
