Sets value of the *Embed* field in Xcode under *Frameworks, Libraries, and Embedded Content* to **Embed Without Signing**

This results in the framework being copied into the built app bundle during the *Embed Libraries* build phase.

```lua
embed ("Foo.framework")
```

### Parameters ###

`value` is the name of the content to be embedded.

## Applies To ###

Project configurations for XCode.

### Availability ###

Premake 5.0.0-beta1 or later.

### Examples ###

```lua
embed {
	"SDL2.dylib",
	"bar.framework"
}
```

### See Also ###

* [embedAndSign](embedandsign.md)
* [Embedding Frameworks in Xcode](Embedding-Frameworks-in-Xcode.md)
