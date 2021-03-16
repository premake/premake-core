Checks for the existence of directory.

```lua
os.isdir("path")
```

### Parameters ###

`path` is the file system path to check.


### Return Value ###

**True** if a matching directory is found; **false** is there is no such file system path, or if the path points to a file instead of a directory.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [os.isfile](os.isfile.md)
* [os.stat](os.stat.md)
