Controls whether multiple processors are used for compilation.

```lua
multiprocessorcompile ("value")
```

## Parameters
`value` is one of:
* `Default`: Use the compiler's default behavior.
* `On`: Use multiple processes for compilation.
* `Off`: Use a single process for compilation.

## Applies To
The `config` scope.

## Availability
Premake 5.0.-beta8 or later for the `msc` toolset or in Visual Studio exporters.
