Specifies the target file extensions for a [custom build rule](Custom-Rules.md).

```lua
fileextension ("ext")
```

### Parameters ###

`ext` is the target file extension for the rule, including the leading dot.


### Applies To ###

Rules.


### Availability ###

Premake 5.0.0-alpha1 or later.


### Examples ###

```lua
rule "Cg"
  display "Cg Compiler"
  fileextension ".cg"
```


### See Also ###

* [Custom Rules](Custom-Rules.md)
* [rule](rule.md)
