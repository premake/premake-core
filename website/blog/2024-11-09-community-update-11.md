---
title: "Community Update #11"
tags: [community-updates]
authors: nickclark2016
---

It's been almost 3 years since the last community update, and over 2 years since the last beta.  Without further ado, here are the community contributions fromt the last 2 years.

### Road to Premake 5.0

Most of the heavy lifting for Premake 5.0 is done, but there are a few major milestones left for leaving beta and going to full release.

1. Deprecation and removal of the [flags](https://premake.github.io/docs/flags) API. Flags are a remenant of older models. Instead, flags will be migrated to the idiomatic Premake approach of dedicated APIs. This isn't going to be as trivial as "On" and "Off", as many of these flags represent a larger group of behaviors.

2. Deprecation and removal of the gmake exporter in favor of gmake2. This has been one of the goals for many years now, and we're confident that gmake2 is in a spot where it can be "promoted" to the primary GNU makefile exporter. In the next release, gmake will likely be renamed and deprecated, and gmake will describe the gmake2 exporter. This will be a breaking change, but we feel it is the best way forward to remove the bifurcation of the makefile exporter. Until the time when we do remove the legacy gmake exporter, users current leveraging the legacy exporter are encouraged to try out the gmake2 exporter and report any defects or feature deficiencies in order to make the change as seamless as possible.

In order to make sure we capture the needs of users for the 5.0 stable release, I encourage you to open issues or discussions to ensure the transition to 5.0 is an easy user experience.

{/* truncate */}

### Community Contributions

- [#1841](https://github.com/premake/premake-core/pull/1841)  Update shadertype.md (@TylerDahl)
- [#1842](https://github.com/premake/premake-core/pull/1842)  Update shaderobjectfileoutput.md (@TylerDahl)
- [#1843](https://github.com/premake/premake-core/pull/1843)  Update shadermodel.md (@TylerDahl)
- [#1942](https://github.com/premake/premake-core/pull/1942)  Release/v5.0 beta2 (@premake)
- [#1951](https://github.com/premake/premake-core/pull/1951)  Fix custom build with missing directory (@Jarod42)
- [#1952](https://github.com/premake/premake-core/pull/1952)  vstudio: add usestandardpreprocessor option (@flakey5)
- [#1954](https://github.com/premake/premake-core/pull/1954)  Add newoption.catagory to documentation, mark os.is as deprecated (@thomashope)
- [#1959](https://github.com/premake/premake-core/pull/1959)  Use admonitions in documentation for things marked as deprecated (@thomashope)
- [#1970](https://github.com/premake/premake-core/pull/1970)  Updated Android docs (@LORgames)
- [#1971](https://github.com/premake/premake-core/pull/1971)  Fixed a couple of issues with the Custom Rules docs (@LORgames)
- [#1975](https://github.com/premake/premake-core/pull/1975)  Strip linking decorators for sibling projects (@LORgames)
- [#1976](https://github.com/premake/premake-core/pull/1976)  Android projects use IncludePath instead of ExternalIncludePath (@LORgames)
- [#1978](https://github.com/premake/premake-core/pull/1978)  Added support for CopyFileToFolders via Copy buildaction (@LORgames)
- [#1980](https://github.com/premake/premake-core/pull/1980)  Added UWP support for VS projects (@LORgames)
- [#1981](https://github.com/premake/premake-core/pull/1981)  Update usefullpaths.md (@nepp95)
- [#1985](https://github.com/premake/premake-core/pull/1985)  Update defaultplatform.md (@GiacomoMaino)
- [#1992](https://github.com/premake/premake-core/pull/1992)  Add AntTarget to vsandroid project file (@0x416c69)
- [#1997](https://github.com/premake/premake-core/pull/1997)  Add validation for toolset. (@Jarod42)
- [#2003](https://github.com/premake/premake-core/pull/2003)  Allow to specify "--cc=msc" as command line. (@Jarod42)
- [#2004](https://github.com/premake/premake-core/pull/2004)  Handle entrypoint for msc. (@Jarod42)
- [#2006](https://github.com/premake/premake-core/pull/2006)  `externalwarnings`, `externalanglebrackets`, `externalincludedirs` was already available in vs2019 (@Jarod42)
- [#2009](https://github.com/premake/premake-core/pull/2009)  Fix typos in comment. (@Jarod42)
- [#2010](https://github.com/premake/premake-core/pull/2010)  Typo fix (@brno32)
- [#2011](https://github.com/premake/premake-core/pull/2011)  Add support for unity builds (@Sharlock93)
- [#2022](https://github.com/premake/premake-core/pull/2022)  Fix Debian build recepie. (@KOLANICH-tools)
- [#2023](https://github.com/premake/premake-core/pull/2023)  Fix support of openmp for visual studio with clang toolset. (@Jarod42)
- [#2024](https://github.com/premake/premake-core/pull/2024)  Fix typo in bytecode description. (@Jarod42)
- [#2025](https://github.com/premake/premake-core/pull/2025)  Fix missing targets file issue in some C++ nuget packages (@hanagasira)
- [#2027](https://github.com/premake/premake-core/pull/2027)  `sanitize { "Address" }` should set link flags too for gcc/clang. (@Jarod42)
- [#2028](https://github.com/premake/premake-core/pull/2028)  Add support for idirafter flag in GCC/Clang (@nickclark2016)
- [#2032](https://github.com/premake/premake-core/pull/2032)  Change to minimize differences after Codelite re-save the file (@Jarod42)
- [#2034](https://github.com/premake/premake-core/pull/2034)  Robustify `http.get` tests with retry. (@Jarod42)
- [#2039](https://github.com/premake/premake-core/pull/2039)  gmake2: Fix detecting msdos vs posix shell (@Peter0x44)
- [#2042](https://github.com/premake/premake-core/pull/2042)  Fix `compileas "C"` and `"C++"` for gcc (shared with clang). (@Jarod42)
- [#2052](https://github.com/premake/premake-core/pull/2052)  Fix typo (@rafaelcn)
- [#2061](https://github.com/premake/premake-core/pull/2061)  Fixed issue with Codelite unit test (@LORgames)
- [#2064](https://github.com/premake/premake-core/pull/2064)  Updated actions from v2 to v3 (@LORgames)
- [#2066](https://github.com/premake/premake-core/pull/2066)  Improve error message of `include` (@Jarod42)
- [#2070](https://github.com/premake/premake-core/pull/2070)  Add support of prelink steps (similar to prebuild steps) for Codelite. (@Jarod42)
- [#2072](https://github.com/premake/premake-core/pull/2072)  Fix prelink step dependencies for gmake (to be done after compilation). (@Jarod42)
- [#2075](https://github.com/premake/premake-core/pull/2075)  remove trailing whitespaces and add new line at eof (@hanagasira)
- [#2076](https://github.com/premake/premake-core/pull/2076)  Allow to select specific version of msc in command line. (@Jarod42)
- [#2081](https://github.com/premake/premake-core/pull/2081)  Add some missing flags for msc toolset (@Jarod42)
- [#2084](https://github.com/premake/premake-core/pull/2084)  Update debugdir.md docs to clarify feature support (@thomashope)
- [#2087](https://github.com/premake/premake-core/pull/2087)  Add clarification for relative paths (@learn-more)
- [#2088](https://github.com/premake/premake-core/pull/2088)  Fix nil indexing for codelite (@Jarod42)
- [#2090](https://github.com/premake/premake-core/pull/2090)  Add support to `undefines` for Codelite. (@Jarod42)
- [#2102](https://github.com/premake/premake-core/pull/2102)  remove reference to non existent example. (@mcarlson-nvidia)
- [#2104](https://github.com/premake/premake-core/pull/2104)  Add VS2022 to list of valid kinds for Android Packaging (@premake)
- [#2117](https://github.com/premake/premake-core/pull/2117)  Require unistd.h for macosx in libzip (@nickclark2016)
- [#2118](https://github.com/premake/premake-core/pull/2118)  Changes target of HTTP tests to hopefully resolve test issues in CI (@nickclark2016)
- [#2122](https://github.com/premake/premake-core/pull/2122)  Fix `premake.findProjectScript` of previous commit. (@Jarod42)
- [#2127](https://github.com/premake/premake-core/pull/2127)  Fixes for using debugger under Linux (@vadz)
- [#2131](https://github.com/premake/premake-core/pull/2131)  Use call array for MSVS filters file generation too (@vadz)
- [#2135](https://github.com/premake/premake-core/pull/2135)  Fix libzip missing a library (@KanuX-14)
- [#2172](https://github.com/premake/premake-core/pull/2172)  Custom LLVM Versions for VS2019+ (@nickclark2016)
- [#2187](https://github.com/premake/premake-core/pull/2187)  Enable code analysis via clang-tidy in Visual Studio (@theComputeKid)
- [#2194](https://github.com/premake/premake-core/pull/2194)  [vs*] Allow to have per-file `cdialect`/`cppdialect`. (@Jarod42)
- [#2195](https://github.com/premake/premake-core/pull/2195)  [vs2010+] Handle `compileas` for files with "unknown" extensions. (@Jarod42)
- [#2203](https://github.com/premake/premake-core/pull/2203)  Add CA root certificate path for Haiku (@augiedoggie)
- [#2217](https://github.com/premake/premake-core/pull/2217)  Add Library to available shadertypes (@vkaytsanov)
- [#2237](https://github.com/premake/premake-core/pull/2237)  [CI] add dependabot.yml to maintain version action up to date (@Jarod42)
- [#2238](https://github.com/premake/premake-core/pull/2238)  Bump the github-actions group with 3 updates (@premake)
- [#2243](https://github.com/premake/premake-core/pull/2243)  Fix stack manipulation in Premake's `luaL_loadfilex` override. (@tritao)
- [#2251](https://github.com/premake/premake-core/pull/2251)  Add a `os.hostarch()` function to get the host system architecture. (@tritao)
- [#2252](https://github.com/premake/premake-core/pull/2252)  Document `os.rename` and `os.getenv` APIs (@tritao)
- [#2253](https://github.com/premake/premake-core/pull/2253)  Add `term.clearToEndOfLine` and `term.moveLeft` API additions. (@tritao)
- [#2254](https://github.com/premake/premake-core/pull/2254)  Adds `desktop` system tag to desktop systems. (@tritao)
- [#2255](https://github.com/premake/premake-core/pull/2255)  Move sanitize, visibility and inlinesvisibility to shared table. (@alex-rass-88)
- [#2261](https://github.com/premake/premake-core/pull/2261)  Add tests for `table.merge`. (@tritao)
- [#2263](https://github.com/premake/premake-core/pull/2263)  Adds a new `os.targetarch()` function. (@tritao)
- [#2264](https://github.com/premake/premake-core/pull/2264)  Show error messages from broken includes (@richard-sim)
- [#2268](https://github.com/premake/premake-core/pull/2268)  Re-structure common docs files into sub-folders. (@tritao)
- [#2269](https://github.com/premake/premake-core/pull/2269)  Upgrade docs to latest Docusaurus version. (@tritao)
- [#2271](https://github.com/premake/premake-core/pull/2271)  Add `linker` flag and `LLD` support. (@tritao)
- [#2272](https://github.com/premake/premake-core/pull/2272)  Fixed issue with include failing to find embedded files (@LORgames)
- [#2274](https://github.com/premake/premake-core/pull/2274)  Port Premake to Cosmopolitan Libc (@tritao)
- [#2277](https://github.com/premake/premake-core/pull/2277)  Add C++23 cppdialect (@jlaumon)
- [#2278](https://github.com/premake/premake-core/pull/2278)  Prevent empty arrays as expected values for test.contains and test.excludes (@LORgames)
- [#2279](https://github.com/premake/premake-core/pull/2279)  Added ci job to simplify required checks in PRs (@LORgames)
- [#2280](https://github.com/premake/premake-core/pull/2280)  Upgrade `libcurl` to latest. (@tritao)
- [#2281](https://github.com/premake/premake-core/pull/2281)  Fix vstudio/MSC not supporting the C++23 flag yet (@jlaumon)
- [#2283](https://github.com/premake/premake-core/pull/2283)  Miscelanneous cleanups (@tritao)
- [#2284](https://github.com/premake/premake-core/pull/2284)  Fix `os.host` for Cosmopolitan build (@tritao)
- [#2287](https://github.com/premake/premake-core/pull/2287)  [doc] Write doc for `unsignedchar` (@Jarod42)
- [#2294](https://github.com/premake/premake-core/pull/2294)  Add projects web and github (@Jarod42)
- [#2299](https://github.com/premake/premake-core/pull/2299)  Remove generated "website/node_modules"'s files from project (@Jarod42)
- [#2301](https://github.com/premake/premake-core/pull/2301)  Fix spelling insice -> inside (@jonesy-b-dev)
- [#2316](https://github.com/premake/premake-core/pull/2316)  Update modules.md (@day-garwood)

Additional gratitude and good wishes to everyone who helped review pull requests and triage issues this cycle. Projects like this don't work without you.

<div style={{textAlign: 'center'}}>
	<a href="https://opencollective.com/_fivem">
		<img src="https://images.opencollective.com/_fivem/2f78b5f/logo/128.png"/>
	</a>
</div>

A big shout out to our premier sponsor **[Cfx.re](https://opencollective.com/_fivem)** and all [our monthly backers](https://opencollective.com/premake#section-contributors)—be sure to check out their work and support them back if you can!

We welcome questions, suggestions, and concerns. Message or DM us at [@premakeapp](https://twitter.com/premakeapp) or [open a discussion on GitHub](https://github.com/premake/premake-core/discussions).
