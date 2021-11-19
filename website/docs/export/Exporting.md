---
title: Exporting
---

The `export` module provides facilities for writing and structuring the contents of workspaces and projects while exporting for a specific toolset.

```lua
local export = require('export')

export.eol('\n')
export.indentString('\t')

export.writeLine('<ProjectConfiguration Include="%s|%s">', cfgName, arch)
export.indent()
export.writeLine('<Configuration>%s</Configuration>', cfgName)
export.writeLine('<Platform>%s</Platform>', arch)
export.outdent()
export.writeLine('</ProjectConfiguration>')
```
