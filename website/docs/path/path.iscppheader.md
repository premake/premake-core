Returns true if the specified path represents a C++ header file, based on its file extension.

```lua
path.iscppheader("path")
```

### Parameters ###

`path` is the file system path to be tested.


### Return Value ###

True if the path matches a well-known C file extension, which currently includes `.h`, `.hh`, `.hpp`, and `.hxx`.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.getextension](path.getextension.md)
* [path.hasextension](path.hasextension.md)
* [path.iscfile](path.iscfile.md)
* [path.iscppfile](path.iscppfile.md)
* [path.isframework](path.isframework.md)
* [path.isobjectfile](path.isobjectfile.md)
* [path.isresourcefile](path.isresourcefile.md)
