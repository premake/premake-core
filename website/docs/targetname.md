Specifies the base file name for the compiled binary target.

```lua
targetname ("name")
```

By default, the project name will be used as the file name of the compiled binary target. A Windows executable project named "MyProject" will produce a binary named MyProject.exe. The `targetname` function allows you to change this default.

### Parameters ###

`name` is the new base file name.

### Applies To ###

Project configurations.

### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
targetname "mytarget"
```

### See Also ###

 * [targetdir](targetdir.md)
 * [targetextension](targetextension.md)
 * [targetprefix](targetprefix.md)
 * [targetsuffix](targetsuffix.md)
