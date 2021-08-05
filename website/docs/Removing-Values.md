---
title: Removing Values
---

The remove...() set of functions remove one or more values from a list of configuration values. Every configuration list in the Premake API has a corresponding remove function: [flags()](flags.md) has removeflags(), [defines()](defines.md) has removedefines(), and so on.

```lua
remove... { "values_to_remove" }
```

## Applies To ##

Project configurations.

## Parameters ##

One or more values to remove. If multiple values are specified, use the Lua table syntax.

## Examples ##

Remove the NoExceptions flag from a previous configuration.

```lua
removeflags "NoExceptions"
```

You can use wildcards in removes. This example will remove both WIN32 and WIN64 from the defines.

```lua
defines { "WIN32", "WIN64", "LINUX", "MACOSX" }
removedefines "WIN*"
```
