Apply whole archive flag to linked libraries.
That would include all their symbols.

```lua
wholearchive "value"
```

### Parameters ###

`value` is one of:

| Value   | Description                                       |
|---------|---------------------------------------------------|
| On      | Turn on whole archive.                            |
| Off     | Turn off whole archive.                           |

### Availability ###

Premake 5.0-beta8 or later.

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
    wholearchive 'On'
-- ..
```

### See Also ###

* [links](links.md)
