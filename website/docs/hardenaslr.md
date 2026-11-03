Specifies whether to enable Address Space Layout Randomization (ASLR).

```lua
hardenaslr "value"
```

### Parameters ###

*value* selects the ASLR setting:

| Value   | Description             |
|---------|-------------------------|
| Default | Add no ASLR override.   |
| Off     | Request disabling ASLR. |
| On      | Request enabling ASLR.  |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.1 or later.

### Limitations ###

Fully static Linux executables and Off for Linux shared libraries are currently unsupported.

Windows does not allow disabling ASLR on ARM, ARM64 or ARM64EC targets.

### Examples ###

```lua
hardenaslr "On"
```

### See Also ###

* [pic](pic.md)
