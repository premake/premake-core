Updates the last modified date of a file without changing its contents.

```lua
ok, err = os.touchfile("filename")
```

### Parameters ###

`filename` is the file system path to the target file.

### Return Value ###

True if successful, otherwise nil and an error message.

### Availability ###

Premake 5.0 or later.
