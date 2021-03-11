Perform a wildcard match to locate one or more directories.

```lua
matches = os.matchdirs("pattern")
```

### Parameters ###

`pattern` is the file system path to search. It may contain single (non-recursive) or double (recursive) asterisk wildcard patterns.



### Return Value ###

A list of directories which match the specified pattern. May be empty.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
matches = os.matchdirs("src/*")      -- non-recursive match
matches = os.matchdirs("src/**")     -- recursive match

matches = os.matchdirs("src/test*")  -- may also match partial names
```


### See Also ###

* [os.matchfiles](os.matchfiles.md)
