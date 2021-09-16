Tells the compiler when it should inline functions.

```lua
inlining ("value")
```

### Parameters ###

`value` is one of:

| Value     | Description                                                        |
|-----------|--------------------------------------------------------------------|
| Default   | Allow the compiler to use its default inlining behavior.           |
| Disabled  | Turn off inlining entirely.                                        |
| Explicit  | Only inline functions explicitly marked with the `inline` keyword. |
| Auto      | Allow the compiler to inline functions automatically.              |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.
