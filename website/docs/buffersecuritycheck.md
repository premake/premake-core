Specifies whether to use stack and buffer protections.

```lua
buffersecuritycheck "value"
```

### Parameters ###

*value* specifies if buffer security checks should be enabled.

| Value   | Description                                            |
|---------|--------------------------------------------------------|
| Off     | Disable buffer security checks.                        |
| On      | Enable buffer security checks.                         |
| Default | Use the default buffer security checks.                |

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0-beta8 or later.

### Examples ###

```lua
buffersecuritycheck "On"
```

[1]: https://learn.microsoft.com/en-us/cpp/build/reference/gs-buffer-security-check?view=msvc-170
[2]: https://gcc.gnu.org/onlinedocs/gcc-15.2.0/gcc/Instrumentation-Options.html#Instrumentation-Options
