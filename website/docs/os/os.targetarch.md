Returns the id of the architecture currently being targeted.
See [architecture](architecture.md) for a complete list of architecture identifiers.

```lua
id = os.targetarch()
```

This will return `nil` by default instead of returning the architecture for the current running
system due to backwards compatibility.

A target architecture can be set either via setting [_TARGET_ARCH](globals/premake_TARGET_ARCH.md) or
by passing an architecture via the `--arch` command line option (which has the most priority).


### Parameters ###

None.


### Return Value ###

An architecture identifier; see [architecture()](architecture.md) for a complete list of identifiers.

Note that this function returns the architecture for the OS that Premake is generating files for, which is not necessarily the same as the architecture for the OS that Premake is currently running on.


### Availability ###

Premake 5.0.0 beta 3 or later.


### Examples ###

```lua
print(os.targetarch())
-- "x86_64"
end
```


### See Also ###

* [_TARGET_ARCH](globals/premake_TARGET_ARCH.md)
* [os.hostarch](os/os.hostarch.md)
* [architecture](architecture.md)
