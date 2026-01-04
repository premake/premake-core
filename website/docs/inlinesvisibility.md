Specifies the inline symbol visibility.

```lua
inlinesvisibility ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| Default | Uses the default visibility |
| Hidden | Inline symbols have hidden visibility |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for GCC and Clang toolsets.

### Examples ###

```lua
inlinesvisibility "Hidden"
```

