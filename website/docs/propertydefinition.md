Creates a new property for a [custom rule](Custom-Rules.md).

```lua
propertydefinition {
  name = "name",
  kind = "kind",
  display = "label",
  description = "message"
}
```

Custom rules, and therefore property definitions, are currently only supported for Visual Studio 2010+.

### Parameters ###

The property definition is specified as a table with the following values. Note that no data validation is currently performed on property definition parameters at this time.

#### name ####

Required; a name for the rule that will be unique in the projects where it is used. This name will be used as the name of the corresponding XML elements in Visual Studio rule files, so avoid spaces and other special characters.

#### kind ####
The expected data type of the values assigned to this property. Allowed values are:

* `boolean` - a yes or no value.
* `integer` - an integer number.
* `list` - a list of string values.
* `number` - a floating point number.
* `path` - a single file system path value.
* `string` - a single string value.

For enum properties, this field is ignored and can be omitted. Otherwise it is required.

#### display ####
A short description of the property to display in the toolset UI (property sheets, etc.)

#### description ####
A longer description of the property to display in the toolset UI (property sheets, etc.)

#### value ####
The default value of the property, if any.

#### values ####
For enum properties, a key-value table of the possible values of the property, along with their text equivalent. See the examples below for more information.

#### switch ####
The value to be placed into the command line for this property. See the examples below for more information.

#### separator ####
For list properties, this sets the value of the list item separator in the command line.
If set, the list is concatenated by the separator and placed behind a single switch. If not set, the switch is duplicated.

#### category ####
Visual Studio only.
If set, the property is placed in a subcategory with the specified name in the VS project properties section. If not set, the property is placed in the subcategory "General".


### Applies To ###

Rules.


### Availability ###

Available in Premake 5.0.0-alpha1 or later for Visual Studio 2010 or later.


### Examples ###

A simple boolean property to control a switch.

```lua
propertydefinition {
  name = "DebuggingSymbols",
  kind = "boolean",
  display = "Debugging Symbols",
  description = "Add debugging information to the generated output",
  value = false,
  switch = "-g"
}
```

To use this property in the rule:

```lua
-- If set to true, evaluates to: `tool.exe -g`
buildcommand "tool.exe [DebuggingSymbols]"
```

Enum properties allow selection from a list of possible values.

```lua
propertydefinition {
  name = "OptimizationLevel",
  display = "Optimization Level",
  values = {
    [0] = "None",
    [1] = "Size",
    [2] = "Speed",
  },
  switch = {
    [0] = "-O0",
    [1] = "-O1",
    [2] = "-O3",
  },
  value = 2,
}
```

Enum properties are set using the value names.

```lua
filter "configurations:Release"
  myCustomRuleVars { OptimizationLevel = "None" }
```

### Old Version issues ###
- As of premake 5.0 alpha13 and earlier, list properties in VS did not work as intended, contents could only be added once as a single element (preprocessed by a table.concat call) or else the project would be illformatted.
