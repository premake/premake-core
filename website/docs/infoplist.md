Sets the application bundle information file for any Apple platform application.

```lua
infoplist ("path")
```

When generating Xcode action, this command will override the auto-detected Info.plist from the project file list.

When used in Console application projects, the Info.plist is embedded in the application binary using Apple toolchain specific linker flags.

### Parameters ###

`path` is the file system path to the Apple property list file to use as Info.plist.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later for Apple platform applications.

### Examples ###

This project defines a default Info.plist and a different one for the Debug configuration.

```lua
project "MyProject"

  infoplist "Default.plist"

  filter { "configurations:Debug" }
    infoplist "DebugInfo.plist"
```

