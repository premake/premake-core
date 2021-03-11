Returns true if the specified path represents a Cocoa framework bundle, based on its file extension.

```lua
path.isframework("path")
```

### Parameters ###

`path` is the file system path to be tested.


### Return Value ###

True if the path matches has a **.framework** extension.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.getextension](path.getextension.md)
* [path.hasextension](path.hasextension.md)
* [path.iscfile](path.iscfile.md)
* [path.iscppfile](path.iscppfile.md)
* [path.iscppheader](path.iscppheader.md)
* [path.islinkable](path.islinkable.md)
* [path.isobjectfile](path.isobjectfile.md)
* [path.isresourcefile](path.isresourcefile.md)
