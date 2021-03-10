Returns the directory portion of a path, with any file name removed.

```lua
p = path.getdirectory("path")
```

### Parameters ###

`path` is the file system path to be split.


### Return Value ###

The directory portion of the path, with any file name removed. If the path does not include any directory information, the "." (single dot) current directory is returned.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [path.getbasename](path.getbasename.md)
* [path.getdrive](path.getdrive.md)
* [path.extension](path.getextension.md)
* [path.getname](path.getname.md)
