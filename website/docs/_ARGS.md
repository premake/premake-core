The `_ARGS` global variable stores any arguments to the current action. As an example, if this command line was used to launch Premake:

```
$ premake5 vs2012 alpha beta
```

...then `_ARGS[1]` will be set to "alpha" and `_ARGS[2]` to "beta". If there are no arguments this array will be empty.


### Availability ###

Premake 4.0 or later.

## See Also ##

* [_ACTION](_ACTION.md)
* [_OPTIONS](_OPTIONS.md)
