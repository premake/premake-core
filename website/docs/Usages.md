---
title: Usages
---

See [moomalade/premake-usage](https://github.com/moomalade/premake-usage).

*Usages* are an idea that has been batted around for years now, but never quite made it to the light of day. The goal it to allow a project script to specify how to *use* a library or component, as opposed to how to build it: what libraries to link, what header files and search paths to include, what symbols to define, and so on.

The syntax proposal is a new call `usage` to define the settings:

```lua
-- Define how to build the project
project "MyLibrary"
   -- …

-- Define how to use the project
usage "MyLibrary"
   links { "my-library" }
   includedirs { "./includes" }
   defines { "MY_LIBRARY" }
```

Another project can then pull these settings in by calling `uses`:

```lua
project "MyApp"
    uses { "MyLibrary" }
```
