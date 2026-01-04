Enables or disables [OpenMP](https://en.wikipedia.org/wiki/OpenMP).

```lua
openmp ("value")
```
If no value is set for a configuration, the toolset's default OpenMP option (usually "Off") will be performed.

### Parameters ###

`value` is one of:

| Value   | Description                                       |
|---------|---------------------------------------------------|
| On      | Turn on OpenMP.                                   |
| Off     | Turn off OpenMP.                                  |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta1 or later for Visual Studio 2010+ and the MSC toolset.
Premake 5.0.0-beta2 or later for the GCC and Clang toolsets and for xcode.

## Examples ##

```lua
openmp "On"
```
