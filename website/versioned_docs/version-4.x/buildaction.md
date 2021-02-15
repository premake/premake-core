The **buildaction** function specifies how a file or set of files should be treated during the compilation process. It is usually paired with a configuration filter to select a file set. If no build action is specified for a file a default action will be used, based on the file's extension.

```lua
buildaction ("action")
```

Build actions are currently only supported for .NET projects, and not for C or C++.

## Applies To ##

Solutions, projects, and configurations.

## Parameters ##

*action* is one of:

|   |   |
|---|---|
| Compile | Treat the file as source code; compile and link it. |
| Embed | Embed the file into the target binary as a resource. |
| Copy | Copy the file to the target directory. |
| None | Do nothing with this file. |

## Examples ##

Embed all PNG image files into the target binary.

```lua
configuration "**.png"
   buildaction "Embed"
```
