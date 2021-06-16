local Buffer = require('buffer')

local export = {}

local _captureBuffer
local _eol = '\n'
local _indentLevel = 0
local _indentString = '\t'


function export.append(...)
	if _captureBuffer == nil then
		error('no active capture', 0)
	end

	if select('#', ...) > 0 then
		Buffer.write(_captureBuffer, string.format(...))
	end
end


function export.appendLine(...)
	export.append(...)
	Buffer.write(_captureBuffer, _eol)
end


function export.capture(fn)
	local oldBuffer = _captureBuffer
	local oldEol = _eol
	local oldLevel = _indentLevel
	local oldIndent = _indentString

	_captureBuffer = Buffer.new()

	fn()
	local result = Buffer.close(_captureBuffer)

	_indentString = oldIndent
	_indentLevel = oldLevel
	_eol = oldEol
	_captureBuffer = oldBuffer
	return result
end


function export.captured()
	if _captureBuffer then
		return Buffer.toString(_captureBuffer)
	else
		return ''
	end
end


function export.eol(value)
	_eol = value or _eol
	return _eol
end


function export.indent(amount)
	_indentLevel = _indentLevel + (amount or 1)
end


function export.indentString(value)
	_indentString = value or _indentString
	return _indentString
end


function export.outdent(amount)
	_indentLevel = _indentLevel - (amount or 1)
	if _indentLevel < 0 then
		_indentLevel = 0
	end
end


---
-- Output a UTF-8 BOM to the exported file.
---

function export.writeUtf8Bom()
	export.write('\239\187\191')
end


function export.write(...)
	if _captureBuffer == nil then
		error('no active capture', 0)
	end

	if select('#', ...) > 0 then
		Buffer.write(_captureBuffer, string.rep(_indentString, _indentLevel))
		Buffer.write(_captureBuffer, string.format(...))
	end
end


function export.writeLine(...)
	export.write(...)
	Buffer.write(_captureBuffer, _eol)
end


return export
