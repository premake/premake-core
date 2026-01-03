Specifies if the compiler should package individual functions as packaged functions (COMDATs).

```lua
functionlevellinking ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | Package indivudal functions as COMDATs. |
| Off   | Do not package individual functions.    |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later for Visual Studio.

### Examples ###

```lua
functionlevellinking "Off"
```

