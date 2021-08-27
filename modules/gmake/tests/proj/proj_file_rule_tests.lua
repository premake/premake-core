local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjFileRulesTests = test.declare('GmakeProjFileRulesTests', 'gmake-proj', 'gmake')


---
-- Tests the file rule outputs with no files.
---
function GmakeProjFileRulesTests.NoFiles()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.fileRules(prj)

	test.capture [[
# File Rules
	]]
end


---
-- Tests the file rule outputs with a single file.
---
function GmakeProjFileRulesTests.SingleFile()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			files({
				'file.c'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.fileRules(prj)

	test.capture [[
# File Rules

$(OBJDIR)/file.o: file.c
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
	]]
end


---
-- Tests the file rules outputs with multiple outputs.
---
function GmakeProjFileRulesTests.MultipleFiles()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			files({
				'file.c',
				'other.c'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.fileRules(prj)

	test.capture [[
# File Rules

$(OBJDIR)/file.o: file.c
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"

$(OBJDIR)/other.o: other.c
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%.o=%.d)" -c "$<"
	]]
end