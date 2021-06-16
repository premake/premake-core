# os.chdir

Changes the current working directory.

```lua
ok, err = os.chdir('path')
```

## Parameters

`path` is the file system path to the new working directory.

## Return Value

`true` if successful, or `nil` and an error message if the current working directory could not be changed.

## Availability

Premake 4.0 or later.

## See Also

- [os.getCwd](os.getCwd.md)
