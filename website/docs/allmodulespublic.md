allmodulespublic

```lua
allmodulespublic "value"
```

### Parameters ###

`value` one of:
* `On` - All C++ modules in the given project(s) will be public.
* `Off` - Not all C++ modules in the given project(s) will be public.

## Applies To ###

The `config` scope.

### Availability ###

Visual Studio 2019 and later.
Premake 5.0-beta2 or later.

### Examples ###

```lua
allmodulespublic "On"
```

