This function sets a boolean flag that controls whether or not the generated projects should adhere ("conform") to a *stricter* interpretation of the language standard or not. 

```lua
conformancemode(is_strict)
```

### Parameters ###

If `is_strict` is true (and applicable to the generated project's capabilities), the generated project will use stricter language standard rules (e.g. C and C++ ISO standards) when building the project. This will increases the chances of the build system and compiler reporting problems with the code you write and build that may not be as portable between compilers or target systems. However, it may also decrease how many platform-specific build system and compiler features are available to you.

On the other hand, if `is_strict` is false then the opposite tradeoff will apply: more features/permissiveness, but less cross-platform compatibility.

## Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 beta 1 or later.

### Examples ###

```lua
conformancemode(true)   -- better for cross-platform projects
conformancemode(false)  -- has access to more platform-specific features

-- Parentheses are required in this case because Lua only supports 
-- omitting them if the parameter is a single string or table.
```

