---
title: Migrating from Premake 4.x
---

# Function name changes

The function [`workspace`](workspace.md) replaces `solution`. The latter still works, but the former is preferred.

The function [`filter`](filter.md) replaces the `configuration` function for specifying the current configuration. It provides a more powerful interface for selecting which configuration is current, making it easy to specify flags for different actions, files, etc. The `configurations` setting at the workspace level still sets the available configurations.

# Flag changes

Many of the old [`flags`](flags.md) have become full-fledged functions. This should be a comprehensive list of such changes.

| Old flags | New Function |
| --------- | ------------ |
| `EnableSSE`, `EnableSSE2` | [`vectorextensions`](vectorextensions.md) |
| `ExtraWarnings`, `NoWarnings` | [`warnings`](warnings.md) |
| `FloatFast`, `FloatStrict` | [`floatingpoint`](floatingpoint.md) |
| `Managed`, `Unsafe` | [`clr`](clr.md) |
| `NativeWChar` | [`nativewchar`](nativewchar.md) |
| `NoEditAndContinue` | [`editandcontinue`](editandcontinue.md) |
| `NoRTTI` | [`rtti`](rtti.md) |
| `OptimizeSize`, `OptimizeSpeed` | [`optimize`](optimize.md) |
