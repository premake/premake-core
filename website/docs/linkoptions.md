Passes arguments directly to the linker command line without translation.

```lua
linkoptions { "options" }
```

## Parameters ##

`options` is a list of linker flags and options, specific to a particular linker.


### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.

### Examples ###

Use `pkg-config` style configuration when building on Linux with GCC. Build options are always linker specific and should be targeted to a particular toolset.

```lua
filter { "system:linux", "action:gmake*" }
  linkoptions { "`wx-config --libs`" }
```
