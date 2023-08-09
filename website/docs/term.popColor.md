Returns the current console color setting and restores the previously saved color setting saved by the last call of [term.pushColor](term.pushColor.md)

``` lua
term.popColor()
```

### Parameters ###
None

### Return Value ###
* `nil` if the color stack is empty.
* The current color setting. One of the color values listed in [term.setTextColor](term.setTextColor.md)

### Example ###
``` lua
local currentColor = term.popColor()
print("Last color setting was: " .. currentColor)
```

### See Also ###
* [term.pushColor](term.pushColor.md)
* [term.getTextColor](term.getTextColor.md)
* [term.setTextColor](term.setTextColor.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.

