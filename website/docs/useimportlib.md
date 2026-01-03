Sets whether or not to generate an import library for a Windows DLL.

```lua
useimportlib ("value")
```

### Parameters ###

`value` specifies the desired import library behavior:

| Value       | Description                                                                           |
|-------------|---------------------------------------------------------------------------------------|
| Default     | Performs the toolset default behavior of generating an import library.                |
| Off         | Prevents the generation of an import library for a Windows DLL.                       |
| On          | Explicitly generates an import library for a Windows DLL.                             |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later.

### Examples ###

```lua
useimportlib "Off"
```

### See Also ###

* [implibdir](implibdir.md)
* [implibextension](implibextension.md)
* [implibname](implibname.md)
* [implibprefix](implibprefix.md)
* [implibsuffix](implibsuffix.md)
