Specifies the target operating system.

```lua
system ("value")
```

If no system is specified, Premake will identify and target the current operating system. This can be overridden with the `--os` command line argument, providing one of the system identifiers below.

### Parameters ###

`value` is one of:

* aix
* android
* bsd
* [emscripten](https://emscripten.org/)
* [haiku](http://www.haiku-os.org)
* ios
* linux
* macosx
* solaris
* uwp
* wii
* windows
* xbox360

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
workspace "MyWorkspace"
   configurations { "Debug", "Release" }
   system { "Windows", "Unix", "Mac" }

   filter "system:Windows"
      system "windows"

   filter "system:Unix"
      system "linux"

   filter "system:Mac"
      system "macosx"
```

### See Also ###

* [architecture](architecture.md)
* [_OS](globals/premake_OS.md)
