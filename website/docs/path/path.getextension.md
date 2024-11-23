Returns the file extension portion of a path.

```lua
p = path.getextension("path")
```

### Parameters ###

`path` is the file system path to be split.


### Return Value ###

The file extension portion of the path, or an empty string if no extension is present.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [path.getbasename](path.getbasename.md)
* [path.getdirectory](path.getdirectory.md)
* [path.getdrive](path.getdrive.md)
* [path.getname](path.getname.md)
