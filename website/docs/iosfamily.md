Specifies the family of iOS device to be targeted.

```lua
iosfamily ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| `iPhone/iPod touch` | iPhones or iPod Touch Devices |
| `iPad` | iPad Devices |
| `Universal` | Universal device target |

## Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha14 or later for XCode.

### Examples ###

```lua
iosfamily "iPhone/iPod touch"
```

