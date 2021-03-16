The **path.getrelative** function computes a relative path from one directory to another.

```lua
p = path.getrelative("src", "dest")
```

### Parameters ###

`src` is the originating directory, `dest` is the target directory. Both may be specified as absolute or relative to the current working directory. The paths do not need to exist on the file system.

### Return Value ###

A relative path from `src` to `dest`.

### Availability ###

Premake 4.0 or later.
