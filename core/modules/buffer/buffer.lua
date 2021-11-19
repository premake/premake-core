---
-- String buffers
---

local Type = require('type')

local Buffer = Type.declare('Buffer')

local Impl = _PREMAKE.buffer


function Buffer.new()
	return Type.assign(Buffer, {
		_buffer = Impl.new()
	})
end


function Buffer.clear(self)
	Impl.clear(self._buffer)
end


function Buffer.close(self)
	return Impl.close(self._buffer)
end


function Buffer.toString(self)
	return Impl.toString(self._buffer)
end


function Buffer.write(self, value)
	Impl.write(self._buffer, value)
end


function Buffer.writef(self, format, ...)
	local str = string.format(format, ...)
	Buffer.write(self, str)
end


return Buffer
