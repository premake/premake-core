Specifies the linker.

```lua
linker ("value")
```

### Parameters ###

`value` is one of:

| Value | Description | Notes |
|-------|-------------|-------|
| Default | Use the toolset default linker. |
| LLD | Use LLVM's LLD linker | Supported by GCC and Clang | 

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta3 or later.

### Examples ###

Sets `LLD` as the linker.

```lua
filter { "toolset:clang" }
   linker { "LLD" }
```
