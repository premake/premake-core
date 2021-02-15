The **buildoptions** function passes arguments directly to the compiler command line without translation.

```lua
buildoptions { "options" }
```

If a project includes multiple calls to **buildoptions** the lists are concatenated, in the order in which they appear in the script.

## Applies To ##

Solutions, projects, and configurations.

## Parameters ##

*options* is a list of compiler flags and options, specific to a particular compiler.

## Examples ##

Use `pkg-config` style configuration when building on Linux with GCC. Build options are always compiler specific and should be targeted to a particular toolset.

```lua
configuration { "linux", "gmake" }
  buildoptions { "`wx-config --cxxflags`", "-ansi", "-pedantic" }
```
