Changes the color of future text printed to the console

```lua
term.setTextColor(color)
```

### Parameters ###
`color` - One of:
  * `nil` (default color)
  * term.black
  * term.blue
  * term.green
  * term.cyan
  * term.red
  * term.purple
  * term.brown
  * term.lightGray
  * term.gray
  * term.lightBlue
  * term.lightGreen
  * term.lightCyan
  * term.lightRed
  * term.magenta
  * term.yellow
  * term.white

For specific purposes the following can be used/overridden:
  * term.warningColor
  * term.errorColor
  * term.infoColor

### Examples ###

Print text in green

```lua
term.setTextColor(term.green)
print("Hello World")
```

### See Also ###
* [term.getTextColor](term.getTextColor.md)
* [term.pushColor](term.pushColor.md)
* [term.popColor](term.popColor.md)

### Availability ###

Premake 5.0.0 alpha 12 or later.

