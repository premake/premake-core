Adds arbitrary GNU make markup to a generated Makefile.

```lua
makesettings { "values" }
```

Only used for makefile generating actions.


### Parameters ###

`values` specifies one or more lines to be written to the Makefile.


### Applies To ###

Project configurations.


### Availability ###

Premake 5.0.0-alpha1 or later.


### Examples ###

```lua
makesettings [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules'
]]
```
