Changes the current working directory.

```lua
ok, err = os.chdir("path")
```

### Parameters ###

`path` is the file system path to the new working directory.

### Return Value ###

**True** if successful, otherwise **nil** and an error message.

### Availability ###

Premake 4.0 or later.

### See Also ###

* [os.getcwd](os.getcwd.md)
* [os.mkdir](os.mkdir.md)
