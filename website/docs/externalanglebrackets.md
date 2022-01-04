Treats all headers included by `#include <header>`, where the header file is enclosed in angle brackets (`< >`), as external headers.

```lua
externalanglebrackets "value"
```

### Parameters ###

`value` is one of:

| Value   | Description                                       |
|---------|---------------------------------------------------|
| On      | Treat headers included with angle brackets as external. |
| Off     | Default. Headers are treated normally. |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.
Visual Studio 2022 version 17.0 or later.

### See Also ###

* [externalincludedirs](externalincludedirs.md)
* [externalwarnings](externalwarnings.md)
