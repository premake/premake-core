Specifies the system architecture to be targeted by the configuration.

```lua
architecture ("value")
```

### Parameters ###

`value` is one of:

* `universal`: The universal binaries supported by iOS and macOS
* `x86`
* `x86_64`
* `ARM`
* `ARM64`
* `RISCV64`
* `armv5`: Only supported in VSAndroid projects
* `armv7`: Only supported in VSAndroid projects
* `aarch64`: Only supported in VSAndroid projects
* `mips`: Only supported in VSAndroid projects
* `mips64`: Only supported in VSAndroid projects

Additional values that are aliases for the above:

* `i386`: Alias for `x86`
* `amd64`: Alias for `x86_64`
* `x32`: Alias for `x86`; There is intent to deprecate this
* `x64`: Alias for `x86_64`; There is intent to deprecate this

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
