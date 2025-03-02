Specifies which usage blocks a project should consume.

```lua
uses { "ProjectA" }
```

The `uses` API is used to consume `usage` blocks from within a project. The `usage` blocks are case sensitive.

### Usage Resolution Priority ###

1. `PUBLIC` and `INTERFACE` usage scopes within a project of the corresponding name.
2. `usage` blocks with the corresponding name in any scopes.

Note: If there are duplicate usage blocks with the same resolved name, the selected usage block is unspecified. `usage` blocks should have unique names if they are not specified as `PUBLIC`, `PRIVATE`, or `INTERFACE`.

### Applies To ###

Projects and usage configurations.

### Examples ###

Demonstration of using `uses`. When specifying a `uses` matching a project name containing a `PUBLIC` or `INTERFACE` usage block, the `uses` statement will match against that. If a `project` with a `PUBLIC` or `INTERFACE` usage block
cannot be found, then it will fall back to searching all `usage` blocks to match the provided name, as described above.

```lua
project "MyProject"
    usage "PUBLIC"
        defines { "PUBLIC_DEF" }
    usage "Custom"
        defines { "CUSTOM_DEF" }

project "MyExe"
    uses { "MyProject" }

project "MyDLL"
    uses { "Custom" }
```

### See Also ###

* [usage](usage.md)