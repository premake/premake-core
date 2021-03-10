Returns the base file portion of a path, with the directory and file extension removed.

```lua
p = path.getbasename("path")
```

### Parameters ###

`path` is the file system path to be split.


### Return Value ###

The base name portion of the supplied path, with any directory and file extension removed.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [path.getdirectory](path.getdirectory.md)
* [path.getdrive](path.getdrive.md)
* [path.extension](path.getextension.md)
* [path.getname](path.getname.md)
