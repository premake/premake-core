Changes the file system permissions of a file.

```lua
ok, err = os.chmod(path, mask)
```

### Parameters ###

`path` is the path to the file on which the permissions should be changed.

`mask` is a string specifying the new permission mask. Currently, only octal number notations is supported, e.g. "755".

### Return Value ###

If successful, returns true. On error, returns nil and an error message.


### Availability ###

Premake 5.0 or later.
