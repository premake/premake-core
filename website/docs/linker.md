Specifies the linker.

```lua
linker ("value")
```

### Parameters ###

`value` is one of:

| Value   | Description                                    | Notes |
|---------|------------------------------------------------|-------|
| Default | Use the toolset default linker.                | |
| BFD     | Use the GNU BFD linker (`ld.bfd`).             | Supported by Clang and GCC. |
| Gold    | Use the GNU gold linker (`ld.gold`).           | Supported by Clang and GCC. Deprecated since binutils 2.44. |
| LLD     | Use LLVM's LLD linker.                         | Supported by Clang and GCC 9 or later. |
| Mold    | Use the mold linker.                           | Supported by Clang and GCC 12.1 or later. |
| Wild    | Use the Wild linker.                           | Supported by Clang and GCC 16.1 or later. |

The selected linker is passed to the compiler driver as `-fuse-ld=<name>`. The linker itself must be installed (i.e. found on the `PATH`).

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later. `BFD`, `Gold`, `Mold` and `Wild` are available in the latest Premake master.

### Examples ###

Sets `LLD` as the linker.

```lua
filter { "toolset:clang" }
   linker "LLD"
```

Configures GCC to use the Mold linker.

```lua
filter { "toolset:gcc" }
   linker "Mold"
```
