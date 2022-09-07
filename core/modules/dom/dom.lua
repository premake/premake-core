local dom = {}

dom.Block = doFile('./src/block.lua', dom)
dom.Config = doFile('./src/config.lua', dom)
dom.Project = doFile('./src/project.lua', dom)
dom.Root = doFile('./src/root.lua', dom)
dom.Workspace = doFile('./src/workspace.lua', dom)

return dom
