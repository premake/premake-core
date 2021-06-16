# os.isFile

Checks for the existence of file.

```lua
result = os.isFile('path')
```

## Parameters

`path` is the file system path to test.

## Return Value

`true` if a matching file is found; `false` is there is no such file system path, or if the path points to a directory instead of a file.

## Availability

Premake 6.0 or later (available in 4.0 or later as `os.isfile`).
