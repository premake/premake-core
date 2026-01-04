Specifies the desired format of the debug information written to the output binaries.

```lua
debugformat ("format")
```

### Parameters ###

`format` specifies the desired debug format:

| Value       | Description                                                                                 |
|-------------|---------------------------------------------------------------------------------------------|
| Default     | Specifies default debug format should be used by toolset.                                   |
| c7          | Specifies that MSVC should store debuginfo in the objects rather than a separate .pdb file. |
| Dwarf       | Needs documentation                                                                         |
| SplitDwarf  | Needs documetation                                                                          |

**Note for Visual Studio Users:** Use [editandcontinue](editandcontinue.md) to control the `/Zi` and `/ZI` switches; see [this discussion](https://github.com/premake/premake-core/issues/1425) for more information.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### See Also ###

- [editandcontinue](editandcontinue.md)

