---
-- Premake helper APIs.
---

local export = require('export')
local State = require('state')
local Store = require('store')

local premake = _PREMAKE.premake

_PREMAKE.VERSION = '6.0.0-next'
_PREMAKE.COPYRIGHT = 'Copyright (c) 2002-2021 Jason Perkins and the Premake Project'
_PREMAKE.WEBSITE = 'https://github.com/starkos/premake-next'

premake.C_HEADER_EXTENSIONS = { '.h', '.inl' }
premake.C_SOURCE_EXTENSIONS = { '.c', '.s' }
premake.CXX_HEADER_EXTENSIONS = { '.hpp', '.hxx' }
premake.CXX_SOURCE_EXTENSIONS = { '.cc', '.cpp', '.cxx', '.c++' }
premake.OBJC_HEADER_EXTENSIONS = { '.hh' }
premake.OBJC_SOURCE_EXTENSIONS = { '.m', '.mm' }
premake.WIN_RESOURCE_EXTENSIONS = { '.rc' }


local _env = {}
local _store = Store.new()
local _testStateSnapshot


---
-- Before running a unit test, snapshot the current baseline configuration, and restore
-- it once the test has completed.
---

onRequire('testing', function (testing)
	local snapshot

	testing.onBeforeTest(function ()
		snapshot = _store:snapshot()
		_store:rollback(_testStateSnapshot)
	end)

	testing.onAfterTest(function ()
		_store:rollback(snapshot)
	end)
end)


function premake.callArray(funcs, ...)
	if type(funcs) == 'function' then
		funcs = funcs(...)
	end
	if funcs then
		for i = 1, #funcs do
			funcs[i](...)
		end
	end
end


function premake.checkRequired(obj, ...)
	local n = select('#', ...)
	for i = 1, n do
		local field = select(i, ...)
		if not obj[field] then
			return false, string.format('missing required value `%s`', field)
		end
	end
	return true
end


function premake.env()
	return _env
end


local _eol

function premake.eol(newValue)
	_eol = newValue or _eol
	return _eol
end


---
-- Calls an exporter function and, if the returned value is different than what is currently
-- stored in `exportPath`, overwrites it with the new contents.
--
-- @param object
--    The object to be exported.
-- @param exportPath
--    The path to the exported file.
-- @param exporter
--    The exporter function to be called; receives `object` as its only parameter.
-- @returns
--    True if a new value was written to `exportPath`; false otherwise.
---

function premake.export(obj, exportPath, exporter)
	local contents = export.capture(function ()
		exporter(obj)
	end)

	if not io.compareFile(exportPath, contents) then
		io.writeFile(exportPath, contents)
		return true
	else
		return false
	end
end


function premake.newState(initialState)
	return State.new(_store, table.mergeKeys(_env, initialState))
end


---
-- Creates a snapshot of the current store state, before the user's project script
-- has run, to enable automated testing without picking up user project artifacts.
---

function premake.snapshotStateForTesting()
	_testStateSnapshot = Store.snapshot(_store)
end


function premake.store()
	return _store
end


return premake
