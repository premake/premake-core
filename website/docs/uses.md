Specifies which usage blocks a project should consume.

```lua
uses { "ProjectA" }
```

The `uses` API is used to consume `usage` blocks from within a project. The `usage` blocks are case sensitive.

### Usage resolve priority ###

1. `PUBLIC` and `INTERFACE` usage scopes within a project of the corresponding name.
2. `usage` blocks with the corresponding name in any scopes.

Note: If there are duplicate usage blocks with the same resolved name, the selected usage block is unspecified. `usage` blocks should have unique names if they are not specified as `PUBLIC`, `PRIVATE`, or `INTERFACE`. If `links` or `linkoptions` are defined within a usage block, it is recommended that `linkgroups` is also turned on.

### Applies To ###

Projects and usage configurations.

### See Also ###

* [linkgroups](linkgroups.md)
* [usage](usage.md)