Writes a string to a file, if the string differs from the current version of the file.

```lua
ok, err = os.writefile_ifnotequal("text", "filename")
```

### Parameters ###

`text` is the string to be written to the file.

`filename` is the file system path to the target file.


### Return Value ###

`1` if successful, `0` if the string is identical to the current file contents, otherwise `-1` and an error message.


### Availability ###

Premake 5.0 or later.
