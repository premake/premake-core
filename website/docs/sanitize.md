Enables various `fsanitize` options for compilers.

```lua
sanitize { "value_list" }
```

### Parameters ###

`value_list` specifies the desired `fsanitize` options to enable.

| Value       | Description                                            |
|-------------|--------------------------------------------------------|
| Address     | Enables compiler support for AddressSanitizer. | Visual Studio support starts with 2019 16.9 |
| Fuzzer      | Enables support for LibFuzzer, a coverage-guided fuzzing library. | Visual Studio support starts with 2019 16.9 |
| Thread      | Enables compiler support for ThreadSanitizer. |
| Undefined   | Enables compiler support for UndefinedBehaviorSanitizer (UBSan). |

### Applies To ###

Project configurations.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
sanitize { "Address", "Fuzzer" }
```
