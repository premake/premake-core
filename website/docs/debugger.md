Specifies the debugger to use.

```lua
debugger ("value")
```

### Parameters ###

`value` is one of:

| Value | Description | Notes |
|-------|-------------|-------|
| Default | Use the default IDE debugger. |
| GDB | Use GDB. | CodeLite only. |
| LLDB | Use LLDB. | CodeLite only. |
| VisualStudioLocal | Use local debugger. | Visual Studio only. |
| VisualStudioRemote | Use remote debugger. | Visual Studio only. |
| VisualStudioWebBrowser | Use web browser debugger. | Visual Studio only. |
| VisualStudioWebService | Use web service debugger. | Visual Studio only. | 

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
debugger "GDB"
```

