Sets whether or not to implicitly link dependent libraries.

```lua
implicitlink ("value")
```

### Parameters ###

*value* specifies the desired implicit link mode:

| Value       | Description                                                                                            |
|-------------|---------------------------------------------------------------|
| Default     | Performs the default implicit link behavior of your exporter. |
| Off         | Do not implicit link dependent libraries.                     |
| On          | Implicitly link dependent libraries.                          |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0-beta8 or later on Visual Studio.
