Scan the well-known system locations looking for a library file.

```lua
p = os.findlib("libname" [, additionalpaths])
```

This function does not work to locate system libraries on macOS 11 or later; it may still be used to locate user libraries. From [the release notes](https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-release-notes):

> New in macOS Big Sur 11.0.1, the system ships with a built-in dynamic linker cache of all system-provided libraries. As part of this change, copies of dynamic libraries are no longer present on the filesystem. Code that attempts to check for dynamic library presence by looking for a file at a path or enumerating a directory will fail.

### Parameters ###

`libname` is name of the library to locate. It may be specified with (`libX11.so`) or without (`X11`) system-specific decorations.

`additionalpaths` is a string or a table of one or more additional search path.

### Return Value ###

The path containing the library file, if found. Otherwise, nil.

### Availability ###

Premake 4.0 or later. Non-macOS host systems only.

