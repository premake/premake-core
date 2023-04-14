Enables Unity Builds in Visual Studio, also known as Jumbo Builds

```lua
enableunitybuild "value"
```

### Parameters ###

`value` is one of:
* `On`  - Enables Unity Builds.
* `Off` - Disables Unity Builds.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 and later. Versions are currently only implemented for Visual Studio 2017+.

### Examples ###

Enable Unity Builds.

```lua
enableunitybuild "On"
```
