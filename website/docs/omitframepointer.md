Controls whether the frame pointer is omitted during compilation.

```lua
omitframepointer ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Default | Use toolset's default behavior. |
| On | Omit frame pointer. |
| Off | Retain frame pointer. |

### Applies To ###
Project and file configurations.

### Availability ###
Premake 5.0.0-alpha14 or later.

### Examples ###
Keep frame pointer in debug builds for better stack traces:
```lua
filter "configurations:Debug"
    omitframepointer "Off"
```

Omit frame pointer in release builds:
```lua
filter "configurations:Release"
    omitframepointer "On"
```

Use compiler defaults across all configurations:
```lua
omitframepointer "Default"
```

## See Also
* [GCC Optimize Options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#index-fomit-frame-pointer) - Documentation on `-fomit-frame-pointer`
* [MSVC Optimization Options](https://docs.microsoft.com/en-us/cpp/build/reference/oy-frame-pointer-omission) - Microsoft Visual C++ frame pointer omission documentation
* [Clang Optimization Options](https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-fomit-frame-pointer) - Clang compiler documentation
