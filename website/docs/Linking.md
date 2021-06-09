---
title: Linking
---

Linking to external libraries is done with the [`links`](links.md) function.

```lua
links { "png", "zlib" }
```

When specifying libraries, system-specific decorations, such as prefixes or file extensions, should be omitted. Premake will synthesize the correct format based on the target platform automatically. The one exception to the rule is Mac OS X frameworks, where the file extension is required to identify it as such.

```lua
links { "Cocoa.framework" }
```

To link to a sibling project (a project in the same workspace) use the **project name**. Premake will deduce the correct library path and name based on the current platform and configuration.

```lua
workspace "MyWorkspace"

   project "MyLibraryProject"
      -- ...project settings here...

   project "MyExecutableProject"
      -- ...project settings here...
      links { "MyLibraryProject" }
```

### Finding Libraries ###

You can tell Premake where to search for libraries with the [`libdirs`](libdirs.md) function.

```lua
libdirs { "libs", "../mylibs" }
```

If you need to discover the location of a library, use the [`os.findlib`](os.findlib.md) function.

```lua
libdirs { os.findlib("X11") }
```
