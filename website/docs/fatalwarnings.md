Specifies specific compiler warnings that should be interpreted as errors.

```lua
fatalwarnings { "warnings" }
```

### Parameters ###

`warnings` is a list of warnings to interpret as errors.

For Visual Studio, the MSC warning number should be used to specify the warning. On other compilers, the warning should be identified by name.

In addition, Premake provides a special value to turn on all compiler warnings.

| Value   | Description                   |
-------------------------------------------
| All | Treat all compiler warnings as errors |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later. Special value `All` available since Premake 5.0-beta5 or later.

### Examples ###

```lua
filter { "toolset:msc" }
	fatalwarnings { "4035" }

filter { "toolset:clang" }
	fatalwarnings { "-Wreturn-type" }
```

### See Also ###

* [enablewarnings](enablewarnings.md)
* [disablewarnings](disablewarnings.md)
