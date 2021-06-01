---
title: Adding Source Files
---

You add files—source code, resources, and so on—to your project using the [files](files.md) function.

```lua
files {
   "hello.h",  -- you can specify exact names
   "*.c",      -- or use a wildcard...
   "**.cpp"    -- ...and recurse into subdirectories
}
```

You can use wildcards in the file patterns to match a set of files. The wildcard \* will match files in one directory; the wildcard \*\* will match files in one directory and also recurse down into any subdirectories.

Files located in other directories should be specified relative to the script file. For example, if the script is located at `MyProject/build` and the source files are at `MyProject/src`, the files should be specified as:

```lua
files { "../src/*.cpp" }
```

Paths should always use the forward slash `/` as a separator; Premake will translate to the appropriate platform-specific separator as needed.

## Excluding Files

Sometimes you want most, but not all, of the files in a directory. In that case, use the [removefiles()](Removing-Values.md) function to mask out those few exceptions.

```lua
files { "*.c" }
removefiles { "a_file.c", "another_file.c" }
```

Excludes may also use wildcards.

```lua
files { "**.c" }
removefiles { "tests/*.c" }
```

Sometimes you may want to exclude all the files in a particular directory, but aren't sure where that directory will fall in the source tree.

```lua
files { "**.c" }
removefiles { "**/Win32Specific/**" }
```
