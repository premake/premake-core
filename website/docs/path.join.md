Joins two path portions together into a single path.

```lua
path.join("leading", "trailing", ...)
```

If trailing is an absolute path, then the leading portion is ignored, and the absolute path is returned instead (see below for examples).


### Parameters ###

`leading` is the beginning portion of the path; `trailing` is a portion to be merged. Multiple arguments may be specified, which will be joined in the order provided.


### Return Value ###

A merged path.


### Availability ###

Premake 4.0 or later.


### Examples ###

```lua
-- returns "MyWorkspace/MyProject"
p = path.join("MyWorkspace", "MyProject")

-- returns "/usr/bin", because the trailing path is absolute
p = path.join("MyWorkspace", "/usr/bin")

-- tokens are assumed to be absolute; this returns "$(ProjectDir)"
p = path.join("MyWorkspace", "$(ProjectDir)")
```
