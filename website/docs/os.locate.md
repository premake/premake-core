Searches the [Premake path](Locating-Scripts.md) for a file.

```lua
os.locate("file_name")
```

### Parameters ###

`file_name` is file name for which to search. It may contain some path information, e.g `xcode/xcode.lua`.


### Return Value ###

The full path to the file if found, or nil if the file could not be located.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [os.pathsearch](os.pathsearch.md)
