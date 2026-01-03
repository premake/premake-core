Specifies a reusable block of configuration to be consumed at a later point.

```lua
usage ('usage')
```

The `usage` API is used to define configuration to be consumed by the `uses` API.  Usages must have unique names, except for magic usage block names (as described below).

### Magic Usage Blocks ###

1. `PRIVATE` - Private specifies a configuration to be automatically applied to the project defining the `usage` block. This block is inaccessible to be consumed by `uses`. This is the equivalent of defining configuration inside the project directly.
2. `INTERFACE` - Interface has the opposite meaning as private usages. An interface usage is applied only to those projects consuming it via `uses`. Interface usage blocks are consumed by specfiying the containing project's name in the `uses` list.
3. `PUBLIC` - Public specifies a configuration to be automatically applied to the project defining the `usage` block and any project consuming it via `uses`. Like `INTERFACE`, it is consumed by specifying the name of the project it is defined in.

If projects define both an `INTERFACE` and `PUBLIC` usage block, both blocks will be applied to any project consuming that project.

### Example ###

```lua
project 'A'
    usage 'PRIVATE'
        defines { 'A_PRIVATE' }
    usage 'PUBLIC'
        defines { 'A_PUBLIC' }
    usage 'NotMagic'
        defines { 'A_NOT_MAGIC' }

project 'B'
    uses { 'NotMagic' } -- Applies usage NotMagic from A

    usage 'PUBLIC'
        uses { 'A' } -- Applies PUBLIC from A to self and to any project consuming B
```

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta7 or later.

### See Also ###

* [uses](uses.md)