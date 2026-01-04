Sets value of the *Embed* field in Xcode under *Frameworks, Libraries, and Embedded Content* to **Embed & Sign**

This results in the framework being copied into the built app bundle during the *Embed Libraries* build phase and signed.

```lua
embedAndSign "SDL2.framework"
```

### Parameters ###

`value` is the name of the content to be embedded and signed.

## Applies To ###

Project configurations for XCode.

### Availability ###

Premake 5.0.0-beta1 or later.

### Examples ###

```lua
embedAndSign {
	"SDL2.framework",
	"Another.framework"
}
```

### See Also ###

* [embed](embed.md)
* [Embedding Frameworks in Xcode](Embedding-Frameworks-in-Xcode.md)
