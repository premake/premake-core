Returns true if the specified path represents a C source code file, based on its file extension.

```lua
path.iscfile("path")
```

### Parameters ###

`path` is the file system path to be tested.


### Return Value ###

True if the path matches a well-known C file extension, which currently includes `.c`, `.s`, and `.m`.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [path.getextension](path.getextension.md)
* [path.hasextension](path.hasextension.md)
* [path.iscppfile](path.iscppfile.md)
* [path.iscppheader](path.iscppheader.md)
* [path.isframework](path.isframework.md)
* [path.islinkable](path.islinkable.md)
* [path.isobjectfile](path.isobjectfile.md)
* [path.isresourcefile](path.isresourcefile.md)
