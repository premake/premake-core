---
title: "Roadmap to 5.0"
tags: [community-updates]
authors: nickclark2016
---

# Road to Premake 5.0

Premake 5.0 is the next major release of the popular build configuration tool, designed to simplify and streamline the process of generating project files for various development environments. This roadmap outlines the key milestones that will be achieved in the journey towards the first stable release of Premake 5.0.

## Milestones
1. **Explicit APIs for Flags**: In the past, Premake has support various flags for project generation, such as `MFC` and `LinkTimeOptimization`. In the 5.0 stable release, all flags will have been replaced by dedicated APIs. The current development builds have already begun this process.
2. **Deprecation and Removal of the gmake Exporter**: For many years now, the `gmake2` exporter has been our suggested generator for GNU Makefiles. As the 5.0 stable release approaches, `gmake` will be moved to `gmakelegacy` and `gmake2` will become `gmake`. It is encouraged that users that are still using the legacy `gmake` exporter to try `gmake2` and report any deficiencies. The deprecation and removal process will happen over the next several beta releases, with planned complete removal within 2025.
3. **Removal of Existing Deprecated APIs**: There are many existing APIs that have been deprecated for several releases now in Premake, both functions and enumerations. To reduce the surface space of the API, existing deprecated APIs with replacements will be removed. Deprecated APIs without a direct replacement will be provided with either a replacement API or instructions on how to replace the behavior (where possible).

## Key Planned Improvements
1. **Better Documentation**: For the 5.0 release, the Premake team will be ensuring that all APIs and public-facing behaviors are sufficiently documented. This includes making sure documentation exists for each of these APIs, as well as sufficient examples of their usage. In addition to increased documentation of the Premake APIs, the guides on how to use and extend Premake will be reviewed to ensure they still demonstrate best practices and reflect upcoming API changes. The documentation will also be reviewed to ensure that there are sufficient examples of extending Premake's functionality.
2. **General Bug Fixes**: There are currently many open bug reports on GitHub for Premake. The team plans to prioritize the bugs and add fixes and tests where possible to prevent future regressions.
3. **Improved Extension Support**: In Premake 5.0-beta3, extending core functionality in Premake, especially exporters, is tedious. As the 5.0 stable release approaches, the team plans to review the mechanisms to extend toolsets and exporters. This may incur a breaking change to external modules using the existing extension mechanisms; however, documentation will be updated as these occur as well as a transition period. For these changes, community feedback is highly encouraged to make sure this is done in a way that everyone benefits from.
4. **Improved CI**: Currently, Premake has many build pipelines for verifying builds on various architectures, as well as running the test suites on those platforms. We are investigating improvements to the CI process, such as improved release artifact generation and more robust pipelines. This effort will also include general improvements to the release creation process.
5. **Increased Testing Coverage**: Premake currently has a large suite of tests, but there are gaps. As part of our push to 5.0, the development team plans to identify and add tests for the gaps in both our public API and internal functionality.

These goals are not all encompassing of Premake 5.0's first stable release, but summarize the high level milestones that the team intends to meet. We look forward to any feedback you have regarding the upcoming changes to Premake. If you are looking to contribute to Premake but don't know where to start, take a look at the GitHub issues list or open a discussion and a member of the team will be able to direct you to where to begin.

Premake would not be possible without the support of the community, our contributors, and our sponsors on [Open Collective](https://opencollective.com/premake). Thank you for your continued support throughout this exciting journey towards 5.0.

The Premake Team
