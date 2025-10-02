Specifies specific linker warnings that should be interpreted as errors.

```lua
linkerfatalwarnings { "warnings" }
```

### Parameters ###

`warnings` is a list of warnings to interpret as errors.

For Visual Studio, the MSC warning number should be used to specify the warning. On other compilers, the warning should be identified by name.

In addition, Premake provides the special value `All` to turn on all linker warnings.

| Value | Description                         |
|-------|-------------------------------------|
| All   | Treat all linker warnings as errors |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later. Special value `All` available since Premake 5.0-beta5 or later.

### Examples ###

```lua
filter { "toolset:msc" }
	fatalwarnings { "4044" } -- unrecognized option 'option'; ignored

filter {}
```
