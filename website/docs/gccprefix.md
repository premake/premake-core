Sets a prefix to be prepended to commands used by the GCC toolchain.

```lua
gccprefix ("prefix")
```

GCC toolsets, and cross-compilers in particular, typically have some common prefix prepended to all tools in the GCC suite. This prefix will be prepended to all such tools.

Prefixes are usually composed of multiple segments separated by '-', and the prefix should contain the final dash.
For instance, a toolchain of the style `powerpc-eabi-gcc` should have gccprefix `powerpc-eabi-`.

### Parameters ###

A *gccprefix* string which is to be prepended to the GCC tools.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Set a GCC prefix to be prepended to the compiler tools.

```lua
gccprefix "powerpc-eabi-"
```
