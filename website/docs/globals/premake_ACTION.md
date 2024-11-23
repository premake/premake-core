---
id: _ACTION
---

The `_ACTION` global variable stores the name of the action to be performed on this execution run. As an example, if this command line was used to launch Premake:

```
$ premake5 vs2013
```

...then `_ACTION` will be set to "vs2013". If there is no action (for instance, if the command was `premake5 --help`) this variable will be nil.

### Availability ###

Premake 4.0 or later.

## See Also ##

* [_ARGS](premake_ARGS.md)
* [_OPTIONS](premake_OPTIONS.md)
