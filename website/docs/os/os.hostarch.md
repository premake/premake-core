Identify the architecture for the currently executing operating system.

```lua
id = os.hostarch()
```

### Parameters ###

None.

### Return Value ###

An architecture identifier; see [architecture()](architecture.md) for a complete list of identifiers.

Note that this function returns the architecture for the OS that Premake is currently running on, which is not necessarily the same as the architecture that Premake is generating files for.

### Availability ###

Premake 5.0.0 beta 3 or later.

### Examples ###

```lua
if os.hostarch() == "x86_64" then
   -- do something x64-specific
end
```

### See Also ###

* [architecture](architecture.md)
