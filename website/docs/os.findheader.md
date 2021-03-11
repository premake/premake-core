Scan the well-known system locations looking for a header file.

```lua
p = os.findheader("headerfile" [, additionalpaths])
```

### Parameters ###

`headerfile` is a file name or a the end of a file path to locate. 

`additionalpaths` is a string or a table of one or more additional search path.

### Return Value ###

The path containing the header file, if found. Otherwise, nil.

### Remarks ###
`os.findheader` mostly use the same paths as [[os.findlib]] but replace `/lib` by `/include`.  

### Availability ###

Premake 5.0 or later.
