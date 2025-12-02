---
title: cdialect
description: Sets the C language dialect for the compiler.
keywords: [premake, cdialect, c dialect, c89, c99, c11, c17, c23, gnu dialects, compiler, project config]
---

Sets the C language dialect for the compiler.

```lua
cdialect "dialect"
```

### Parameters ###

| Dialect | Description                           |
| ------- | ------------------------------------- |
| Default | The default C dialect for the toolset |
| C89     | ISO C89 standard                      |
| C90     | ISO C90 standard                      |
| C99     | ISO C99 standard                      |
| C11     | ISO C11 standard                      |
| C17     | ISO C17 standard                      |
| C23     | ISO C23 standard                      |
| gnu89   | GNU dialect of ISO C89                |
| gnu90   | GNU dialect of ISO C90                |
| gnu99   | GNU dialect of ISO C99                |
| gnu11   | GNU dialect of ISO C11                |
| gnu17   | GNU dialect of ISO C17                |
| gnu23   | GNU dialect of ISO C23                |


### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
cdialect "dialect"
```

