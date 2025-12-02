---
title: characterset
description: Set the character encoding.
keywords: [premake, characterset, character encoding, unicode, mbcs, ascii, compiler, project config]
---

Set the character encoding.

```lua
characterset("set")
```

### Parameters ###

| Set     | Description                                                         |
| ------- | ------------------------------------------------------------------- |
| Default | The default encoding for the toolset; usually Unicode               |
| MBCS    | Multi-byte Character Set; currently supported only in Visual Studio |
| Unicode | Unicode character encoding                                          |
| ASCII   | No actual character set; plain 7-bit ASCII encoding                 |

### Applies To ###

Project configurations.


### Availability ###

Premake 5.0 or later.
