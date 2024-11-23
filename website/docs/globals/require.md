An extension of [Lua's require() function](http://www.lua.org/pil/8.1.html) which adds support for Premake modules and version checking.

```lua
require ("modname", "versions")
```

Premake will use its [extended set of module locations](Locating-Scripts.md) when locating the requested module.

### Parameters ###

`modname` is the name of the module to be loaded. See [Locating Scripts](Locating-Scripts.md) for more information about how Premake modules are located.

`versions` is an optional string of a version requirements. See the examples below for more information on the format of the requirements string. If the requirements are not met, an error will be raised.


### Returns ###

The module object.


### Availability ###

Premake 5.0 or later.


### Examples ###

Require Premake version 5.0 or later.

```lua
require("premake", ">=5.0")
```

If no operator is specified, defaults to ">=". I think it is a little more readable to include it though.

```lua
require("premake", "5.0")
```

Require a version 5.0 alpha 3 or later.

```lua
require("premake", ">=5.0.0-alpha3")
```

Require anything between Premake version 5.1 and 6.0.

```lua
require("premake", ">=5.0 <6.0")
```

The same rules apply to third-party modules.

```lua
require("foo", ">=1.1")
```


### See Also ###

* [_PREMAKE_VERSION](globals/premake_PREMAKE_VERSION.md)
