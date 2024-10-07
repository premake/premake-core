Returns true if the specified path represents a file that can be linked against, based on its file extension.

```lua
path.islinkable("path")
```

### Parameters ###

`path` is the file system path to be tested.


### Return Value ###

True if the path matches a well-known linkable file extension, which currently includes `.o`, `.obj`, `.a`, `.lib`, and `.so`.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.getextension](path.getextension.md)
* [path.hasextension](path.hasextension.md)
* [path.iscfile](path.iscfile.md)
* [path.iscppfile](path.iscppfile.md)
* [path.iscppheader](path.iscppheader.md)
* [path.isframework](path.isframework.md)
* [path.isobjectfile](path.isobjectfile.md)
* [path.isresourcefile](path.isresourcefile.md)
