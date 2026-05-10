Writes a string to a file, if the string differs from the current version of the file.

```lua
ok, err = os.writefile_ifnotequal("text", "filename")
```

### Parameters ###

`text` is the string to be written to the file.

`filename` is the file system path to the target file.


### Return Value ###

The first return value:

| Value | Explanation                                          |
|-------|------------------------------------------------------|
| 1     | The string was written to the file                   |
| 0     | The string is identical to the current file contents |
| -1    | An error occurred                                    |

The second return value is an error message if the first return value is -1, otherwise nil.


### Availability ###

Premake 5.0 or later.
