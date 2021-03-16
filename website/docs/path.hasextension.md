Returns true if a file system path has the given file extension.

```lua
path.hasextension("path", "ext")
```

### Parameters ###

`path` is the file system path to be tested.

`ext` is the file extension to check. May be a single string or an array of strings.


### Return Value ###

True if `path` matches any of the provided file extensions.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.getextension](path.getextension.md)
* [path.iscfile](path.iscfile.md)
* [path.iscppfile](path.iscppfile.md)
* [path.iscppheader](path.iscppheader.md)
* [path.isframework](path.isframework.md)
* [path.islinkable](path.islinkable.md)
* [path.isobjectfile](path.isobjectfile.md)
* [path.isresourcefile](path.isresourcefile.md)
