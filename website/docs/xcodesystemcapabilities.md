Specifies a set of system capabilities to enable in the target.

```lua
xcodesystemcapabilities (table)
```

### Parameters ###

`table` is a table where keys are the capability and values are if they should be enabled or disabled.

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later.

### Examples ###

```lua
xcodesystemcapabilities {
    ["com.apple.InAppPurchase"] = "ON",
    ["com.apple.GameCenter.iOS"] = "OFF",
}
```

