Enables various `fsanitize` options for compilers.

```lua
sanitize { "value_list" }
```

### Parameters ###

`value_list` specifies the desired `fsanitize` options to enable.

| Value             | Description                                            | Notes |
|-------------------|--------------------------------------------------------|---|
| Address           | Enables compiler support for AddressSanitizer (ASan). | Visual Studio support starts with 2019 16.9 |
| Fuzzer            | Enables support for LibFuzzer, a coverage-guided fuzzing library. | Unsupported with GCC. Visual Studio support starts with 2019 16.9 |
| Thread            | Enables compiler support for ThreadSanitizer (TSan). | GCC & Clang only |
| UndefinedBehavior | Enables compiler support for UndefinedBehaviorSanitizer (UBSan). | GCC & Clang only |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
sanitize { "Address", "Fuzzer" }
```
