Saves the current text color state and changes the color of future text printed to the console.
Use [term.popColor](term.popColor.md) to restore the previous color setting.

``` lua
term.pushColor(color)
```

### Parameters ###
* `color` - See the listing in [term.setTextColor](term.setTextColor.md)

### Example ###
``` lua
-- set text to green
term.pushColor(term.green)
print("Hello World")
```

### See Also ###
* [term.popColor](term.popColor.md)
* [term.getTextColor](term.getTextColor.md)
* [term.setTextColor](term.setTextColor.md)


### Availability ###

Premake 5.0.0 alpha 12 or later.

