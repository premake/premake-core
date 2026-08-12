Controls whether assembly output is generated for source files (in addition to normal compilation).

```lua
generateassembly ("value")
```

### Parameters ###

`value` specifies the desired behavior:

| Value   | Description                                                              |
|---------|--------------------------------------------------------------------------|
| Default | Use the toolset or action's default behavior for this file.              |
| On      | Generate assembly output while continuing to produce the normal object. |
| Verbose | Generate assembly output with source code or explanatory comments.       |
| Off     | Disable assembly output.                                                 |

Notes:

- GCC and Clang use `-save-temps=obj` when `generateassembly` is `On`. `Verbose` additionally uses `-fverbose-asm`.
- MSVC uses `/FA` for `On` and `/FAs` for `Verbose`.
- Assembly files are written to the object directory.

### Applies To ###

Project configurations and files.

### Availability ###

Premake 5.0.0 or later.

### Examples ###

Generate assembly for a configuration, with verbose output for one file:

```lua
filter "configurations:Debug"
   generateassembly "On"

filter { "configurations:Debug", "files:main.cpp" }
   generateassembly "Verbose"
```
