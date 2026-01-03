inheritdependencies

```lua
inheritdependencies ("value")
```

For Visual Studio project files, this controls the generation of the `%(AdditionalDependencies)` entry in the list of libraries that a project links.

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| On    | The project(s) will inherit library dependencies based on the parent project (if any) and project default settings. This is the default behavior. |
| Off   | The project(s) will not inherit any library dependencies. Only explicitly specified dependencies will be linked. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta2 or later for Visual Studio 2015+.

### Examples ###

```lua
inheritdependencies "Off"
```

