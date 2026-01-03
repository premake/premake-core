Specify if generated file from [`buildcommands`](buildcommands.md) should be compiled or not.

```lua
compilebuildoutputs ("value")
```

### Parameters ###

`value` one of:

| Value | Description |
|-------|-------------|
| On    | Generated file should be compiled. |
| Off   | Generated file should not be compiled. |

### Applies To ###

File configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
filter "files:**.cpp.in"
  buildmessage "generate %{file.basename} from %{file.relpath}"
  buildoutputs { "%{cfg.objdir}/%{file.basename}") }
  buildcommands { "MyScript %[%{!file.abspath}] %[%{!cfg.objdir}/%{file.basename}]" }
  compilebuildoutputs "on"
filter "files:**.h.in"
  buildmessage "generate %{file.basename} from %{file.relpath}"
  buildoutputs { "%{cfg.objdir}/%{file.basename}") }
  buildcommands { "MyScript %[%{!file.abspath}] %[%{!cfg.objdir}/%{file.basename}]" }
  compilebuildoutputs "off"
filter {}
```

## See Also ##

* [Custom Build Commands](Custom-Build-Commands.md)
