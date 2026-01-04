Enables or disables Visual Studio Just My Code debugging feature by passing /JMC option to the compiler. This applies only to VS C++ projects.

```lua
justmycode ("value")
```
If no value is set for a configuration, the toolset's default option (usually "On") will be performed.

### Parameters ###

`value` is one of:

| Value   | Description                                       |
|---------|---------------------------------------------------|
| On      | Turn on JustMyCode debugging support.                                   |
| Off     | Turn off JustMyCode debugging support.                                  |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha1 or later for Visual Studio 2017+ (15.8+).

## Examples ##

```lua
justmycode "Off"
```
