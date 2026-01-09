Specifies the target operating system.

```lua
system ("value")
```

If no system is specified, Premake will identify and target the current operating system. This can be overridden with the `--os` command line argument, providing one of the system identifiers below.

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| aix | IBM AIX |
| android | Android Platform |
| bsd | BSD Variants |
| emscripten | Emscripten targets |
| haiku | Haiku OS |
| hurd | GNU Hurd |
| ios | Apple iOS |
| linux | Linux Variants |
| macosx | Apple MacOSX |
| solaris | Oracle Solaris |
| tvos | Apple TVos |
| uwp | Universal Windows Platform |
| wii | Nintendo Wii |
| windows | Microsoft Windows |

To note: `emscripten` at the moment is only supported for the `gmake` and `gmakelegacy` actions.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

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
