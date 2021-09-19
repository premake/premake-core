Enables or disables [OpenMP](https://en.wikipedia.org/wiki/OpenMP).

```lua
openmp "value"
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

Premake 5.0-beta1 or later. Currently only implemented for Visual Studio 2010+. As a workaround for other toolsets, you can use [buildoptions](buildoptions.md) like this:

```lua
filter "toolset:not msc*"
	buildoptions "-fopenmp"
```

## Examples ##

```lua
openmp "On"
```