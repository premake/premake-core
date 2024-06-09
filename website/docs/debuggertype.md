debuggertype

```lua
debuggertype "value"
```

### Parameters ###

`value` one of:
* `Mixed` - Enables simultanoues debugging of native and .NET Framework code.
* `NativeOnly` - Restricts debugging to native code only.
* `ManagedOnly` - Restricts debugging to managed code only.
* `NativeWithManagedCore` - Enables simultanoues debugging of native and .NET Core code.

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
debuggertype "value"
```

