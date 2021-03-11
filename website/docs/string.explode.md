Returns an array of strings, each of which is a substring formed by splitting on the provided pattern.

```lua
parts = string.explode("str", "pattern")
```

### Parameters ###

`str` is the string to be split. *pattern* is the separator pattern at which to split; it may use Lua's pattern matching syntax.


### Return Value ###

A list of substrings.


### Examples ###

```lua
e = "a\nmulti\nline\nstring\n"
> for k,v in next, string.explode(e, "\n") do print(k, v) end
1	a
2	multi
3	line
4	string
5	
```


### Availability ###

Premake 4.0 or later.


### See Also ###

* [string.startswith](string.startswith.md)
