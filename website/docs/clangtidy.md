Enables clang-tidy code analysis for Visual Studio.

The `clangtidy` option enables running clang-tidy code analysis in Visual Studio and gmake2 projects.

```lua
clangtidy("value")
```

### Parameters ###

`value` is one of:

- `On`
- `Off`

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 3 or later. Implemented for Visual Studio 2019 and later, and gmake2.

### See Also ###

* [Using Clang-Tidy in Visual Studio](https://learn.microsoft.com/en-us/cpp/code-quality/clang-tidy?view=msvc-170)
* [runcodeanalysis](runcodeanalysis.md)
