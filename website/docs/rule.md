Creates a new custom rule, and makes it the active configuration scope.

```lua
rule ("name")
```

Rules contain the settings and property definitions for a single custom rule file. These settings include the target file extension, the command line format, and the build inputs and outputs.


### Parameters ###

`name` is the name for the rule, which must be unique for each rule specified. If a rule with the given name already exists, it is made active and returned.

If no name is given, the current rule scope is returned, and also made active.

By default, the rule name will be used as the file name of the generated rule files; be careful with spaces and special characters. You can override this default with [filename()](filename.md) and [location()](location.md).

### Availability ###

Premake 5.0.0-alpha1 or later.

### Examples ###

Create a new rule named "luac". For a more complete example, see [Custom Rules](Custom-Rules.md).

```lua
rule "luac"
  fileExtension ".lua"
```

### See Also ###

* [Custom Rules](Custom-Rules.md)
* [externalrule](externalrule.md)
* [propertydefinition](propertydefinition.md)
* [rules](rules.md)
