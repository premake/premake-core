Specifies the stack protection level.

```lua
hardenstack "value"
```

### Parameters ###

*value* selects the protection level:

| Value   | [GCC][2] and [Clang][3]  | [MSVC][1] | Description                                                       |
|---------|--------------------------|-----------|-------------------------------------------------------------------|
| Default |                          |           | Uses compiler default behavior for stack protection.              |
| Off     | -fno-stack-protector     | /GS-      | Disable stack protection, including toolset defaults.             |
| On      | -fstack-protector        | /GS       | Protect functions the compiler considers vulnerable.              |
| Strong  | -fstack-protector-strong | /GS       | Provides at least as strong of protection guarantees as `On`.     |
| All     | -fstack-protector-all    | /GS       | Provides at least as strong of protection guarantees as `Strong`. |

### Applies To ###

Project and file configurations.

### Availability ###

Premake 5.0.1 or later.

### Examples ###

```lua
hardenstack "Strong"
```

```lua
filter "configurations:Release"
	hardenstack "All"
```

### See Also ###

* [buffersecuritycheck](buffersecuritycheck.md) (alias)

[1]: https://learn.microsoft.com/en-us/cpp/build/reference/gs-buffer-security-check?view=msvc-170
[2]: https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html
[3]: https://clang.llvm.org/docs/ClangCommandLineReference.html
