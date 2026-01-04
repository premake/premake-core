Sets the [function calling convention](https://en.wikipedia.org/wiki/X86_calling_conventions).

```lua
callingconvention ("value")
```

### Parameters ###

`value` is one of:

| Value      | Description |
|------------|-------------|
| Cdecl      | `cdecl` calling convention |
| FastCall   | `fastcall` calling convention |
| StdCall    | `stdcall` calling convention |
| VectorCall | `vectorcall` calling convention |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later.
