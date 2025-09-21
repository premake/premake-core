omitframepointer - This page was auto-generated. Feel free to help us improve the documentation by creating a pull request.

```lua
omitframepointer (value)
```

### Parameters

`value` is one of:

* `Default`: Use the compiler’s default behavior. The compiler decides whether to omit the frame pointer based on optimization settings and target architecture.
* `On`: Omit the frame pointer. This frees up a register for optimization, resulting in smaller and faster code, but makes debugging and stack traces less reliable.
* `Off`: Keep the frame pointer. This provides more accurate stack traces and easier debugging at the cost of some optimization opportunities.

## Applies To

The `config` scope.

### Availability

Premake 5.0.0 alpha 14 or later.

### Examples

```lua
-- Keep frame pointer in debug builds for better stack traces
filter "configurations:Debug"
    omitframepointer "Off"

-- Omit frame pointer in release builds for performance
filter "configurations:Release"
    omitframepointer "On"
```
