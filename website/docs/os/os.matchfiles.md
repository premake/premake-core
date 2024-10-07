Perform a wildcard match to locate one or more files.

```lua
matches = os.matchfiles("pattern")
```

### Parameters ###

`pattern` is the file system path to search. It may contain single (non-recursive) or double (recursive) asterisk wildcard patterns.



### Return Value ###

A list of files which match the specified pattern. May be empty.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
matches = os.matchfiles("src/*.c")   -- non-recursive match
matches = os.matchfiles("src/**.c")  -- recursive match
```


### See Also ###

* [os.matchdirs](os.matchdirs.md)
