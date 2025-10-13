:::caution
**This function has been deprecated.** Use [os.istarget()](os.istarget.md), [os.target()](os.target.md), or [os.host()](os.host.md) instead.
:::

Checks the current operating system identifier against a particular value.

```lua
os.is("id")
```

### Parameters ###

`id` is an operating system identifier; see [system()](system.md) for a complete list of identifiers.

Note that this function tests against the OS being targeted, which is not necessarily the same as the OS on which Premake is being run. If you are running on Mac OS X and generating Visual Studio project files, the identifier is "Windows", since that is the OS being targeted by the Visual Studio action.


### Return Value ###

**True** if the supplied ID matches the current operating system identifier, **false** otherwise.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [os.istarget](os.istarget.md)
* [os.target](os.target.md)
* [os.host](os.host.md)
* [os.getversion](os.getversion.md)
