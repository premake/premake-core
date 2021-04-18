Specifies the default libraries to be ignored for a project.

```lua
ignoredefaultlibraries { "libraries" }
```

### Parameters ###

'libraries' is a list of library names. If a valid extension isn't present, `.lib` will be automatically appended, similar to [links](links.md). Currently, the valid extensions are `.lib` and `.obj`.

### Applies To ###

Projects.

### Availability ###

Premake 5.0 or later.

### Examples ###

Specify `MSVCRT.lib` as a default library to ignore.

```lua
project "MyProject"
  ignoredefaultlibraries { "MSVCRT" }
```

## See Also ##

* [links](links.md)