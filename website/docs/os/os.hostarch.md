Identify the architecture for the currently executing operating system.

```lua
id = os.hostarch()
```

### Parameters ###

None.

### Return Value ###

An architecture identifier; see [architecture()](architecture.md) for a complete list of identifiers.

:::warning
Currently, this function actually returns the architecture of the system that Premake was compiled for. This means that if you run the Win32 version of Premake on a 64-bit Windows system, this function will return 'x86' instead of 'x86_64'.
:::

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
