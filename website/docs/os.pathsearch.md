Searches a collection of paths for a particular file.

```lua
p = os.pathsearch("fname", "path1", ...)
```

### Parameters ###

`fname` is the name of the file being searched. This is followed by one or more path sets to be searched.

Path sets match the format of the PATH environment variable: a colon-delimited list of paths. On Windows, you may use a semicolon-delimited list if drive letters might be included.


### Return Value ###

The path to the directory which contains the file, if found. Otherwise, nil.


### Availability ###

Premake 4.0 or later.


### See Also ###

* [os.locate](os.locate.md)
