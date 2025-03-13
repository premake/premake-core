Enable or disable instrumented performance profiling support for binaries.

```lua
profile "value"
```

### Parameters ###
| Value   | Description                                                             |
-------------------------------------------------------------------------------------
| Default | Use the toolset's default instrumentated performance profiling setting. |
| On      | Turn on instrumented performance profiling.                             |
| Off     | Turn off instrumented performance profiling.                            |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0-beta6 or later.

### Examples ###

```lua
project "MyProject"
    kind "ConsoleApp"
    profile "On"
```