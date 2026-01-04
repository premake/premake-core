Specifies the debugger type.

```lua
debuggertype ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Mixed | Enables simultaneous debugging of native and .NET Framework code. |
| NativeOnly | Restricts debugging to only native code. |
| ManagedOnly | Restricts debugging to only managed code. |
| NativeWithManagedCore | Enables simultaneous debugging of native and .NET Core code. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
debuggertype "Mixed"
```

