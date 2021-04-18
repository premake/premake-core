Copies a file from one location to another.

```lua
ok, err = os.copyfile("source", "destination")
```

### Parameters ###

`source` is the file system path to the file to be copied.

`destination` is the path to the copy location.

### Return Value ###

**True** if successful, otherwise **nil** and an error message.

### Availability ###

Premake 5.0 or later.
