Returns the canonical absolute path of a filename.

```lua
ok, err = os.realpath(path)
```

This functions calls [realpath()](http://linux.die.net/man/3/realpath) on Posix systems and [_fullpath](http://msdn.microsoft.com/en-us/library/506720ff.aspx) on Windows.

### Parameters ###

`path` is the path to be converted.

### Return Value ###

If successful, returns the canonical absolute path. On error, returns nil and an error message.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [os.getcwd](os.getcwd.md)
