Sets the version of the MFC libraries to link against.

```lua
mfc "On"
```

### Parameters ###

*value* specifies the desired PIC mode:

| Value       | Description                                                                                            |
|-------------|--------------------------------------------------------------------------------------------------------|
| Default     | Perform the default linkage against the MFC libraries for your project type.                           |
| Off         | Do not link against MFC libraries.                                                                     |
| On          | Link against the MFC libraries corresponding with the runtime type you are using (static or dynamic).  |
| Static      | Force static linkage to the MFC libraries.                                                             |
| Dynamic     | Force dynamic linkage to the MFC libraries.                                                            |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0-beta4 or later on Visual Studio.
