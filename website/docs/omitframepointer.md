Controls whether the frame pointer is omitted during compilation.

```lua
omitframepointer (value)
```

## Parameters
`value` is one of:
* `Default`: Use the compiler's default behavior.
* `On`: Omit the frame pointer.
* `Off`: Keep the frame pointer.

## Applies To
The `config` scope.

## Availability
Premake 5.0.0 alpha 14 or later.

## Examples
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
* [LLVM Function Attributes](https://llvm.org/docs/LangRef.html#function-attributes) - LLVM documentation on frame pointer handling
* [MSVC Optimization Options](https://docs.microsoft.com/en-us/cpp/build/reference/oy-frame-pointer-omission) - Microsoft Visual C++ frame pointer omission documentation
* [Clang Optimization Options](https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-fomit-frame-pointer) - Clang compiler documentation
