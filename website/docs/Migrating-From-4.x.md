---
title: Migrating from Premake 4.x
---

# Function name changes

The function [`workspace`](workspace) replaces `solution`. The latter still works, but the former is preferred.

The function [`filter`](filter) replaces the `configuration` function for specifying the current configuration. It provides a more powerful interface for selecting which configuration is current, making it easy to specify flags for different actions, files, etc. The `configurations` setting at the workspace level still sets the available configurations.

# Flag changes

Many of the old [`flags`](flags) have become full-fledged functions. This should be a comprehensive list of such changes.

| Old flags | New Function |
| --------- | ------------ |
| `EnableSSE`, `EnableSSE2` | [`vectorextensions`](vectorextensions) |
| `ExtraWarnings`, `NoWarnings` | [`warnings`](warnings) |
| `FloatFast`, `FloatStrict` | [`floatingpoint`](floatingpoint) |
| `Managed`, `Unsafe` | [`clr`](clr) |
| `NativeWChar` | [`nativewchar`](nativewchar) |
| `NoEditAndContinue` | [`editandcontinue`](editandcontinue) |
| `NoRTTI` | [`rtti`](rtti) |
| `OptimizeSize`, `OptimizeSpeed` | [`optimize`](optimize) |
