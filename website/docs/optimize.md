The **optimize** function specifies the level and type of optimization used while building the target configuration.

```lua
optimize "value"
```

If no value is set for a configuration, the toolset's default optimization (usually none) will be performed.

### Parameters ###

*value* specifies the desired level of optimization:

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Off         | No optimization will be performed.                     |
| On          | Perform a balanced set of optimizations.               |
| Debug       | Optimization with some debugger step-through support.  |
| Size        | Optimize for the smallest file size.                   |
| Speed       | Optimize for the best performance.                     |
| Full        | Full optimization.                                     |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.

## Examples ##

```lua
optimize "Speed"
```