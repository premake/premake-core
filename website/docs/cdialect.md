Specifies the C dialect to compile with.

```lua
cdialect ("value")
```

### Parameters ###

`value` one of:

| Value   | Description |
|---------|-------------|
| Default | Default C dialect for the toolset |
| C89     | ISO C89 Standard |
| C90     | ISO C90 Standard |
| C99     | ISO C99 Standard |
| C11     | ISO C11 Standard |
| C17     | ISO C17 Standard |
| C23     | ISO C23 Standard |
| gnu89   | GNU Dialect of ISO C89 |
| gnu90   | GNU Dialect of ISO C90 |
| gnu99   | GNU Dialect of ISO C99 |
| gnu11   | GNU Dialect of ISO C11 |
| gnu17   | GNU Dialect of ISO C17 |
| gnu23   | GNU Dialect of ISO C23 |

### Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
cdialect "C11"
```

