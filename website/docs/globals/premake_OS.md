---
id: _OS
---

:::caution
**This has been deprecated in Premake 5.0 alpha 12.** Use the new [_TARGET_OS](premake_TARGET_OS.md) instead.
:::

Stores the name of the operating system currently being targeted; see [system()](system.md) for a complete list of OS identifiers.

The current OS may be overridden on the command line with the `--os` option.

```
$ premake5 --os=linux gmake
```

### Availability ###

Premake 4.0 or later.


## See Also ##

* [_TARGET_OS](premake_TARGET_OS.md)
* [Using Premake](Using-Premake.md)
