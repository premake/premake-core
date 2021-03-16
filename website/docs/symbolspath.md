Specify the target location of the debug symbols.
For the Visual Studio action, this allows you to specify the location and name of the .pdb output. 

```lua
symbolspath "filename"
```

Not specifying this option will result in the compilers default behavior.

### Parameters ###

`filename` the target location of the symbols.

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

This project while specific to Visual Studio shows how to output the .pdb file right next to the lib/exe/dll using the name of the lib/exe/dll itself.

```lua
project "MyProject"
    symbolspath '$(OutDir)$(TargetName).pdb'
```
