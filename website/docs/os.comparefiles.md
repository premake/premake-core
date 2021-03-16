Compares two files for binary equality.

```lua
equality, err = os.comparefiles("filename1", "filename2")
```

### Parameters ###

`filename1` is the file system path to the first file to compare file.

`filename2` is the file system path to the second file to compare file.


### Return Value ###

True if the file are identical by content, false if not, returns nil and an error message if an error occurred.


### Availability ###

Premake 5.0 or later.
