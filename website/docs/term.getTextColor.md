Retrieves the current color setting of text printed to the console

```lua
term.getTextColor()
```

### Parameters ###
None

### Return Value ###
The current color setting. One of the color values listed in [term.setTextColor](term.setTextColor.md)

### Example ###
``` lua
local currentColor = term.getTextColor()
print("Current color setting is: " .. currentColor)
```

### See Also ###
* [term.setTextColor](term.setTextColor.md)
* [term.pushColor](term.pushColor.md)
* [term.popColor](term.popColor.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.

