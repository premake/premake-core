Appends an extension to a file path if it is not already present.

```lua
p = path.appendExtension(p, ext)
```

### Parameters ###

`p` is a file system path.

`ext` is the extension to append to the path.


### Return Value ###

A new file system path with the extension appended, if it was not already part of the path.


### Availability ###

Premake 5.0 or later.


### See Also ###

* [path.join](path.join.md)
