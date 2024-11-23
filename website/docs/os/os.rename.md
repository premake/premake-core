Rename file system files or directories.

```lua
os.rename("path", "newpath")
```

### Parameters ###

`path` is the file system path to be renamed.
`newpath` is the renamed file system path.


### Return Value ###

True if successful, otherwise nil and an error message.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [os.rmdir](os.rmdir.md)
* [os.matchfiles](os.matchfiles.md)


### Examples ###

```lua
local ok, err = os.rename{"file.bak", "file.log"}
if not ok then
	error(err)
end
```
