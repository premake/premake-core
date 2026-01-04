Specifies which C++ Standard Library to use.

```lua
stl ("value")
```

The `stl` API is used to determine which STL is used.

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| none  | Minimal C++ runtime library. |
| gabi++ | Google/Android C++ runtime library |
| stlport | STLport runtime library |
| gnu | GNU STL library |
| libc++ | LLVM libc++ library |

* `none`: Minimal C++ runtime library.
* `gabi++`: C++ runtime library.
* `stlport`: STLport runtime library.
* `gnu`: GNU STL library.
* `libc++`: LLVM libc++ library.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0-alpha14 or later for Visual Studio Android projects.

### Examples ###

```lua
stl "libc++"
```

