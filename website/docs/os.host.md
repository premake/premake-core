Identify the currently executing operating system.

```lua
id = os.host()
```

### Parameters ###

None.

### Return Value ###

An operating system identifier; see [system()](system.md) for a complete list of identifiers.

Note that this function returns the OS that Premake is currently running on, which is not necessarily the same as the OS that Premake is generating files for. If you are running on Mac OS X and generating Visual Studio project files, the identifier is "macosx".

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
if os.host() == "windows" then
   -- do something Windows-specific
end
```

### See Also ###

* [os.get](os.get.md)


