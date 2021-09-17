Passes arguments directly to the resource compiler command line without translation.

```lua
resoptions { "options" }
```

### Parameters ###

`options` is a list of resource compiler flags and options, specific to a particular compiler.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Use `pkg-config` style configuration when building on Linux with GCC. Build options are always compiler specific and should be targeted to a particular toolset.

```lua
filter { "system:linux", "action:gmake" }
  resoptions { "`wx-config --cxxflags`", "-ansi", "-pedantic" }
```
