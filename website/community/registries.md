---
title: Registries
---

These registries are available from other developers for managing Premake modules and libraries. If you have created a registry you would like to share, feel free to [add a link](https://github.com/premake/premake-core/edit/master/website/community/registries.md) to the list!

## Premake Manager

The following registries are fully integrated with **premake-manager**.

### [Common Registry](https://github.com/lolrobbe2/premake-common-registry)

A collection of public and popular libraries designed to integrate seamlessly with **premake**.

* **Dependency Management:** Libraries can declare dependencies, version ranges, and more.
* **Version Matching:** The `premake-manager-cli` automatically matches and installs the correct versions.
* **Customizable:** These registries are created via GitHub repositories and premake manager; users can create their own common registries and add them to their specific workflows via **premake-manager-cli** and derived extensions.

### [Public Registry](https://premake-registry-ywxg.onrender.com/)

The public registry is a hub for individual Premake users who want to share their libraries and modules with the community.

* **Easy Registration:** Modules can be registered via a web UI using GitHub login.
* **Flexible Integration:** While they integrate with `premake-manager-cli`, they are also designed to be used standalone (e.g., as Git submodules).
* **Search API:** Provides a public API dedicated to searching for available modules and libraries, allowing for integration into external tools and scripts.

---

> [!NOTE]
> Developers are encouraged to create their own common registries to manage internal dependencies within their team's specific Premake workflow.
