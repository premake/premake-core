Determines if a given file system path is absolute.

```lua
path.isabsolute("path")
```

### Parameters ###

`path` is the file system path to check.

### Return Value ###

True if the file system path is absolute, false otherwise. The tests include checking for a leading forward or backward slash, a dollar sign (indicating a environment variable), or a DOS drive letter.

### Availability ###

Premake 5.0 or later.

### See Also ###

* [path.getabsolute](path.getabsolute.md)
* [path.getrelative](path.getrelative.md)
