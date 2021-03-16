Identify the currently targeted operating system.

```lua
id = os.get()
```

### Parameters ###

None.


### Return Value ###

An operating system identifier; see [system()](system.md) for a complete list of identifiers.

Note that this function returns the OS being targeted, which is not necessarily the same as the OS on which Premake is being run. If you are running on Mac OS X and generating Visual Studio project files, the identifier is "Windows", since that is the OS being targeted by the Visual Studio action.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
if os.get() == "windows" then
   -- do something Windows-specific
end
```


### See Also ###

* [os.getversion](os.getversion.md)
