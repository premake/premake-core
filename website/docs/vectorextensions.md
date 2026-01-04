Specifies the level of vector processing extensions to enable while compiling the target configuration.

```lua
vectorextensions ("level")
```

If no value is set for a configuration, the toolset's default vector extension settings will be used.

### Parameters ###

`level` specifies the desired level of vector processing instructions; one of the following:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Default     | Use the toolset's default vector extension settings.   |
| AVX         | Use Advanced Vector Extensions.                        |
| AVX2        | Use Advanced Vector Extensions 2.                      |
| IA32        | Use Intel Architecture 32-bit                          |
| SSE         | Use the basic SSE instruction set.                     |
| SSE2        | Use the SSE2 instruction set.                          |
| SSE3        | Use the SSE3 instruction set.                          |
| SSSE3       | Use the SSSE3 instruction set.                         |
| SSE4.1      | Use the SSE4.1 instruction set.                        |
| SSE4.2      | Use the SSE4.2 instruction set.                        |
| ALTIVEC     | Use Altivec (ISA 2.02) instruction set.                |
| NEON        | Use the NEON instruction set (Android only)            |
| MXU         | Use the XBurst SIMD instructions (Android only)        |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

```lua
-- Enable SSE2 vector processing
vectorextensions "SSE2"
```

### See Also ###

* [floatingpoint](floatingpoint.md)
