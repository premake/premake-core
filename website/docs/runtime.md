Choose the type of runtime library to use.

```lua
runtime ("type")
```

If the runtime type is not set, Premake will try to determine the configuration type based on the setting of symbol generation and optimization flags and use the appropriate runtime automatically.

### Parameters ###

`type` is a string value, one of "Debug" or "Release".

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

Force selection of a release runtime.

```lua
filter { "configurations:Debug" }
   symbols "On"
   runtime "Release"
```
