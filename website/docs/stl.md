Specifies which C++ Standard Library to use.

```lua
stl ("value")
```

The `staticruntime` API is used to determine if a static or shared version of the STL is used.

### Parameters ###

`value` is one of:

* `none`: Minimal C++ runtime library.
* `gabi++`: C++ runtime library.
* `stlport`: STLport runtime library.
* `gnu`: GNU STL library.
* `libc++`: LLVM libc++ library.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
stl "libc++"
```

### See Also ###

 * [staticruntime](staticruntime.md)
