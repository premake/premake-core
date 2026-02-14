Get list of file paths contained in an archive.

```lua
local entries, err = zip.list(sourceZip)
```

### Parameters ###
- `sourceZip` is the zip file which has to be extracted

### Return Value ###

A new table containing the path of files contained in the archive, following with error string.

### Availability ###

Premake 5.0.0 or later.

