Takes a path which is relative to one location and makes it relative to another location instead.

```lua
path.rebase("relative_path", "old_base", "new_base")
```

### Parameters ###

`relative_path` is a file system path, specified relative to `old_base`, which is to be rebased.

`new_base` is the location from which it should be made relative.


### Return Value ###

A relative path from *new_base*.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.getabsolute](path.getabsolute.md)
* [path.getrelative](path.getrelative.md)
