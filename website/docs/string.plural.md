Returns a plural version of the provided string.

```lua
pl = string.plural("str")
```

### Parameters ###

`str` is the string to be made plural.


### Return Value ###

A plural version of the provided string.


### Availability ###

Premake 5.0 or later.


### Examples ###

```lua
-- returns "projects"
pl = string.plural("project")

-- returns "stories"
pl = string.plural("story")
```
