---
title: architecture
description: Specifies the system architecture to be targeted by the configuration.
keywords: [premake, architecture, system, config, x86, x86_64, arm, arm64, riscv64, wasm]
---

Specifies the system architecture to be targeted by the configuration.

```lua
architecture ("arch")
```

### Parameters ###

| Arch        | Description                                        |
| ----------- | -------------------------------------------------- |
| universal   | Universal binaries supported by iOS and macOS      |
| x86         | 32-bit x86 architecture                            |
| x86_64      | 64-bit x86 architecture                            |
| ARM         | 32-bit ARM architecture                            |
| ARM64       | 64-bit ARM architecture                            |
| RISCV64     | 64-bit RISC-V architecture                         |
| loongarch64 | 64-bit LoongArch architecture                      |
| ppc         | 32-bit PowerPC architecture                        |
| ppc64       | 64-bit PowerPC architecture                        |
| wasm32      | 32-bit WebAssembly target                          |
| wasm64      | 64-bit WebAssembly target                          |
| e2k         | Elbrus 2000 architecture                           |
| mips64el    | 64-bit MIPS little-endian architecture             |
| armv5       | ARMv5 (only supported in VSAndroid projects)       |
| armv7       | ARMv7 (only supported in VSAndroid projects)       |
| aarch64     | AArch64 (only supported in VSAndroid projects)     |
| mips        | MIPS (only supported in VSAndroid projects)        |
| mips64      | 64-bit MIPS (only supported in VSAndroid projects) |

:::note
Additional values that are aliases for the above:
:::

| arch  | Description                                      |
| ----- | ------------------------------------------------ |
| i386  | Alias for `x86`                                  |
| amd64 | Alias for `x86_64`                               |
| x32   | Alias for `x86`; there is intent to deprecate    |
| x64   | Alias for `x86_64`; there is intent to deprecate |


### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

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
