Specifies the system architecture to be targeted by the configuration.

```lua
architecture ("value")
```

### Parameters ###

`value` is one of:

* `x86`
* `x86_64`
* `ARM`

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

Set up 32- and 64-bit Windows builds.

```lua
workspace "MyWorkspace"
   configurations { "Debug32", "Release32", "Debug64", "Release64" }

   filter "configurations:*32"
      architecture "x86"

   filter "configurations:*64"
      architecture "x86_64"
```

### See Also ###

* [system](system.md)
