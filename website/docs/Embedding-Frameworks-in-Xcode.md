---
title: Embedding Frameworks in Xcode for App Distribution
---

In order to build a distributeable mac app it is typical to embed the resources your app depends on, including libraries and frameworks, inside the .app folder structure itself. Additionally you must sign all bundled executables for the app to be accepted for notarization.

The snippet below shows an example of the Xcode specific settings you need to set so that you can generate a *.xcodeproj* and have it build an app ready for distribution without needing to manually adjust settings in the Xcode UI.

Before attempting to setup your premake generated project make sure you are able to set all the required settings manually from the UI at least once, and export your app successfully for distribution. Doing this will allow Xcode to handle any one time setup or certificate generation for you, and provide you with a point of comparison if your generated project has issues.

Some things to note:
* *Info.plist* and *.entitlements* files need to be specified twice. Once in the `files` section where paths are relative to the premake script, and once under `xcodebuildsettings` where the path is relative to the generated *.xcodeproj*.
* Adding a third party framework such as *SDL2.framework* requires four steps. `links` to link the framework, `frameworkdirs` to tell Xcode where to find it while building, `sysincludedirs` points to the framework headers, and `embedAndSign` to correctly embed the framework.
* `@executable_path/../Frameworks` must be added to `"LD_RUNPATH_SEARCH_PATHS"` to tell the built executable where to search for frameworks inside the .app bundle.

```lua
-- mac specific settings
filter "action:xcode4"
	files {
		"source/mac/Info.plist", -- add your own your .plist and .entitlements so you can customise them
		"source/mac/app.entitlements",
	}

	links {
		"third_party/sdl2/macos/SDL2.framework",    -- relative path to third party frameworks
		"CoreFoundation.framework",                 -- no path needed for system frameworks
		"OpenGL.framework",
	}

	sysincludedirs {
		"third_party/sdl2/macos/SDL2.framework/Headers", -- need to explicitly add path to framework headers
	}

	frameworkdirs {
		"third_party/sdl2/macos/", -- path to search for third party frameworks
	}

	embedAndSign {
		"SDL2.framework" -- bundle the framework into the built .app and sign with your certificate
	}

	xcodebuildsettings {
		["MACOSX_DEPLOYMENT_TARGET"] = "10.11",
		["PRODUCT_BUNDLE_IDENTIFIER"] = 'com.yourdomain.yourapp',
		["CODE_SIGN_STYLE"] = "Automatic",
		["DEVELOPMENT_TEAM"] = '1234ABCD56',                                    -- your dev team id
		["INFOPLIST_FILE"] = "../../source/mac/Info.plist",                     -- path is relative to the generated project file
		["CODE_SIGN_ENTITLEMENTS"] = ("../../source/mac/app.entitlements"),     -- ^
		["ENABLE_HARDENED_RUNTIME"] = "YES",                                    -- hardened runtime is required for notarization
		["CODE_SIGN_IDENTITY"] = "Apple Development",                           -- sets 'Signing Certificate' to 'Development'. Defaults to 'Sign to Run Locally'. not doing this will crash your app if you upgrade the project when prompted by Xcode
		["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/../Frameworks", -- tell the executable where to find the frameworks. Path is relative to executable location inside .app bundle
	}
```

### See Also

* [embed](embed.md)
* [embedAndSign](embedandsign.md)

### External Resources

* [All About Notarization at WWDC2019](https://developer.apple.com/videos/play/wwdc2019/703)
* [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)