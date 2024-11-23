Function retrieves information about a file.

```lua
info = os.stat("path")
```

### Parameters ###

`path` is the file system path to the file for which to retrieve information.


### Return Value ###

If successful, a table of values:

| Field | Description                 |
|-------|-----------------------------|
| mtime | Last modified timestamp     |
| size  | The file size in bytes      |


### Availability ###

Premake 4.4 or later.


### See Also ###

* [os.isdir](os.isdir.md)
* [os.isfile](os.isfile.md)
