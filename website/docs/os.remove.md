Remove files from the file system.

```lua
os.remove("path", ...)
```

### Parameters ###

`path` is the file system path to be removed. Wildcard matches are supported, see [os.matchfiles](os.matchfiles.md) for examples.


### Return Value ###

True if successful, otherwise nil and an error message.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [os.rmdir](os.rmdir.md)
* [os.matchfiles](os.matchfiles.md)


### Examples ###

```lua
local ok, err = os.remove{"**.bak", "**.log"}
if not ok then
	error(err)
end
```
