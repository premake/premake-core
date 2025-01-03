Turns on or off the linkgroups for option for linked libraries.

Notes:

Projects using GCC or Clang will use order dependent linking by default with the default linker. While it is generally believed to be slower, this option enables order independent linking within a group of libraries by putting them inside of a link-group using the `-Wl,--start-group` and `-Wl,--end-group` linker command line arguments.

```lua
linkgroups ("value")
```

### Parameters ###

`value` is one of:

| Value   | Description                                       |
|---------|---------------------------------------------------|
| On      | Turn on link groups.                              |
| Off     | Turn off link groups.                             |

### Applies To ###

Project configurations

### Availability ###

Premake 5.0-alpha10 or later. GCC and Clang toolsets only. Codelite, gmakelegacy, and gmake exporters only.

### Examples ###

```lua
project "A"
    kind "StaticLib"

project "B"
    kind "StaticLib"
    links { "A" }

project "C"
    kind "ConsoleApp"
    links { "A", "B" }
    linkgroups "On"
```

### See Also ###
* [links](links.md)