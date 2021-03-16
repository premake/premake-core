Enable or disable [run-time type information](https://en.wikipedia.org/wiki/Run-time_type_information).

```lua
rtti ("value")
```

### Parameters ###

`value` is one of:

|         |                                                   |
|---------|---------------------------------------------------|
| Default | Use the toolset's default setting for run-time type information. |
| On      | Turn on RTTI.                                     |
| Off     | Turn off RTTI.                                    |

More values may be added by [add-on modules](Modules.md).


### Applies To ###

Project configurations.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [exceptionhandling](exceptionhandling.md)
