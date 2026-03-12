Command linker to include all objects of given libraries.

```lua
wholearchive { "libraries" }
```

### Parameters ###

`libraries` is the list of static libraries for which to include all their symbols.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
project 'some_library'
    kind 'StaticLib'
    defines { 'MAKING_DLL_LIB' } -- for dllexport
-- ..
project 'some_dll'
    kind 'SharedLib'
    defines { 'MAKING_DLL_LIB' } -- for dllexport
    links { 'some_library' }
    wholearchive { 'some_library' }
-- ..
```

### See Also ###

* [links](links.md)
