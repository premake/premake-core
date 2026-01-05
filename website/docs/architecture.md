Specifies the system architecture to be targeted by the configuration.

```lua
architecture ("value")
```

### Parameters ###

`value` is one of:

| Value       | Description | Notes |
|-------------|-------------|-------|
| universal   | Universal binaries supported by iOS and macOS |
| x86         | x86 Architecture |
| x86_64      | x86_64 Architecture |
| ARM         | 32-bit ARM Architecture |
| AARCH64     | 64-bit ARM Architecture |
| RISCV64     | 64-bit RISCV Architecture |
| loongarch64 | 64-bit LoongArch Architecture |
| ppc         | 32-bit PowerPC Architecture |
| ppc64       | 64-bit PowerPC Architecture |
| wasm32      | 32-bit WASM Architecture |
| wasm64      | 64-bit WASM Architecture |
| e2k         | Elbrus-2000 Architecture |
| mips64el    | 64-bit MIPS (Little Endian) Architecture |
| armv5       | ARMv5 Architecture | Only supported in VSAndroid projects |
| armv7       | ARMv7 Architecture | Only supported in VSAndroid projects |
| mips        | 32-bit MIPS Architecture | Only supported in VSAndroid projects |
| mips64      | 64-bit MIPS Architecture | Only supported in VSAndroid projects |

Additional values that are aliases for the above:

| Value | Description |
|-------|-------------|
| ARM64 | Alias for `AARCH64` |
| amd64 | Alias for `x86_64` |
| i386  | Alias for `x86` | Deprecated in Premake 5.0.0-beta8. Use `x86` with `buildoptions { '-march=i386' }`. |
| x32   | Alias for `x86`. | Deprecated in Premake 5.0.0-beta8. There is currently no support for `x32` ABI. |
| x64   | Alias for `x86_64`. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Set up 32- and 64-bit Windows builds.

```lua
workspace "MyWorkspace"
   configurations { "Debug32", "Release32", "Debug64", "Release64" }

   filter "configurations:*32"
      architecture "x86"

   filter "configurations:*64"
      architecture "x86_64"
```

### See Also ###

* [system](system.md)
