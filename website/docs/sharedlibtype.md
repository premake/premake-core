Specifies the shared library type for Apple targets.

```lua
sharedlibtype ("value")
```

### Parameters ###

`value` is one of:

| Value | Description |
|-------|-------------|
| OSXBundle | Shared library is an OSX Bundle |
| OSXFramework | Shared library is an OSX Framework |
| XCTest | Shared library is an XCode test |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0.0-alpha12 or later.

### Examples ###

```lua
sharedlibtype "OSXBundle"
```

