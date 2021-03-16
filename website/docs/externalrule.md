Provides a way to reference rules that were created manually, outside of Premake.

```lua
externalrule ("name")
```

The `externalrule()` function behaves just like [rule()](rule.md), except that it does not output any rule file(s) at project generation time. You may use it to reference a hand-written or pre-existing rule file.


### Parameters ###

`name` is name of the rule. As with [rule()](rule.md), it is used as the default file name, and may be overridden with [filename](filename.md) and [location](location.md).


### Availability ###

Premake 5.0 or later; currently Visual Studio only.


## Examples ##

```lua
externalrule "luac"
  location "../rules"  -- optional; if the file lives somewhere other than the script folder
  filename "lua-to-c"  -- optional; if the file has a name different than the rule
  fileextension ".lua" -- required; which files should be associated with the rule?

  propertydefinition {
    name = "StripDebugInfo",
    kind = "boolean",
  }
```

`fileextension()` is required; this tells Premake which files in the project should be associated with the rule. `location()` is optional, and only needs to be specified if the rule files lives somewhere other than the folder containing the script. Likewise, `filename()` only needs to be specified if the rule file has a different name than the rule itself.

You do not need to specify all of the properties in the rule, only those you intend to set from your project scripts.

The external rule file does not need to exist at the time the workspace is generated.
