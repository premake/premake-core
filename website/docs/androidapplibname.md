---
title: androidapplibname
description: Specfies the file name for the output APK.
keywords: [premake, android, apk, filename, config]
---

Specfies the file name for the output APK.

```lua
androidapplibname ("filename")
```

By default, the project name will be used as the file name for the APK.

### Parameters ###

`filename` **string** - is the new file name.

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 14 or later.

### Examples ###

```lua
androidapplibname "MyProject"
```

