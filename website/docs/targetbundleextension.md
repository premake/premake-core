Specifies the bundle extension for the MacOSX bundle.

```lua
targetbundleextension ("ext")
```

By default, the project will use the MacOSX's normal naming conventions: .bundle for OSX Bundles, .framework for OSX Framework, and so on. The `targetbundleextension` function allows you to change this default.

### Parameters ###

`ext` is the new bundle extension, including the leading dot.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 beta 7 or later.

### Examples ###

```lua
targetbundleextension ".zmf"
```

### See Also ###

 * [targetextension](targetextension.md)
 * [targetname](targetname.md)
 * [targetdir](targetdir.md)
 * [targetprefix](targetprefix.md)
 * [targetsuffix](targetsuffix.md)
