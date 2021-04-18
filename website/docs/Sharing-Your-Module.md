---
title: Sharing Your Module
---

## Versioning

To ensure compatibility, Premake allows project script authors to specify a minimum version or range of versions for the modules they require.

```lua
require("foo", ">=1.1")
```

To support this feature, your module should include a `_VERSION` field specifying the current version.

```lua
m._VERSION = "1.0.0"         -- for the 1.0 release
m._VERSION = "1.0.0-dev"     -- for the development (i.e. what's in your code repository) version
m._VERSION = "1.0.0-alpha3"  -- for a pre-release version
```

When updating your version number between releases, try to follow the conventions set by the [semantic versioning](http://semver.org) standard.

## Publishing

If you intend your module to be available to the public, consider creating a new repository on [GitHub](http://github.com/) (where Premake is hosted) for it, and taking a look at some of the [existing third-party modules](/community/modules) for examples. Some tips:

* Name your repository something like `premake-modulename`

* Include a `README.md` file which explains what your module does, how to use it, and any requirements it has on other modules or libraries.

* Set up a wiki and briefly document any new features and functions it adds. See [Premake's own documentation](https://github.com/premake/premake-core/wiki) for lots of examples.

Finally, regardless of where you host it, be sure to add a link on the [Available Modules](/community/modules) page to help people find it.
