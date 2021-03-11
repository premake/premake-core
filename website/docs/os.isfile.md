Checks for the existence of file.

```lua
os.isfile("path")
```

### Parameters ###

`path` is the file system path to check.


### Return Value ###

**True** if a matching file is found; **false** is there is no such file system path, or if the path points to a directory instead of a file.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [os.isdir](os.isdir.md)
* [os.stat](os.stat.md)
