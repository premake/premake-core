Specifies the linker.

```lua
linker("value")
```

### Parameters ###

`value` string, one of:

* `Default` - uses the toolset platform default linker.
* `LLD` - uses LLVM's LLD linker (supported on `gcc` and `clang` toolsets).

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0 beta 3 or later.

### Examples ###

Sets `LLD` as the linker.

```lua
filter { "toolset:clang" }
   linker { "LLD" }
```
