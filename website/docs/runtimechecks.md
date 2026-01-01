Controls whether runtime error checking is enabled for Visual Studio C/C++ projects.

```lua
runtimechecks ("value")
```

If no value is set for a configuration, the toolset's default behavior will be used. By default, runtime checks are enabled for debug builds.

### Parameters ###

`value` specifies the desired behavior:

| Value                  | Description                                          |
|------------------------|------------------------------------------------------|
| Off                    | Turns off runtime error checking                     | 
| Default                | Use the toolset default behavior (Default value)     |
| StackFrames            | Enables runtime checks for stack frames              |
| UninitializedVariables | Enables runtime checks for uninitialized variables   |
| FastChecks             | Enables all fast runtime checks                      |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta8 or later in Visual Studio only.

### Examples ###

Disable runtime checks:

```lua
runtimechecks "Off"
```

Enable runtime checks even in optimized builds:

```lua
filter { "configurations:Release" }
	optimize "On"
	runtimechecks "FastChecks"
```
