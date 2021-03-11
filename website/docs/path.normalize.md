Tries to create a clean file system representation of a path.

```lua
path.normalize("path")
```

Normalization includes removing duplicate and trailing slashes, leading "./" sequences, and filtering out "../" sequences where possible.


### Parameters ###

`path` is the path to be normalized.


### Return Value ###

The normalized path.


### Availability ###

Premake 5.0 or later.
