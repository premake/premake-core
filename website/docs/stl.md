Specifies which C++ Standard Library to use.

```lua
stl ("value")
```

The `stl` API is used to determine which STL is used.

### Parameters ###

`value` is one of:

| Value   | Description                         |
|---------|-------------------------------------|
| none    | Minimal C++ runtime library.        |
| gabi++  | Google/Android C++ runtime library. |
| stlport | STLport runtime library.            |
| gnu     | GNU STL library.                    |
| libc++  | LLVM libc++ library.                |

If unset, the toolset default library is used.

### Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Limitations ###

Visual Studio only supports this setting for Android projects. GCC and Clang support gnu and libc++ on Linux and Windows from Premake 5.0.1. GCC also needs to be built with libc++ support to select a library.

### Examples ###

```lua
stl "libc++"
```
