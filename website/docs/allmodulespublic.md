Specifies if all modules in the C++ projects are public.

```lua
allmodulespublic ("value")
```

### Parameters ###

`value` is one of:
 
| Value | Description |
|-------|-------------|
| On    | All C++ modules in the given project(s) will be public. |
| Off   | Not all C++ modules in the given project(s) will be public. |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-beta2 and later for Visual Studio 2019 and later.

### Examples ###

```lua
allmodulespublic "On"
```

