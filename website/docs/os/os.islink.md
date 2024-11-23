Determines if the given path is a symlink or reparse point.

```lua
os.islink(path)
```

### Parameters ###

`path` is the path to the file or directory to be checked.


### Return Value ###

Returns true if the path represents a symlink or Windows reparse point; false otherwise.


### Availability ###

Premake 5.0 or later.
