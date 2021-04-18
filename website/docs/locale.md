Specifies the target locale for the resources in a particular configuration.

```lua
locale "code"
```

This value is currently only used for the Microsoft Visual Studio resource compiler in C/C++ projects.

### Parameters ###

`code` specifies the desired locale code. See [the Microsoft documentation on culture codes](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo%28v=vs.85%29.ASPX) for a complete table.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

## Examples ##

```lua
locale "en-GB"
```
