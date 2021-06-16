---
-- Overrides and extensions to Lua's `io` library.
---

local path = require('path')


---
-- Replacement `io.open()` which creates any missing subdirectories if the
-- the file path being opened is set to writeable.
---

function io.open(filename, mode)
	if mode and (string.contains(mode, 'w') or string.contains(mode, 'a')) then
		local dir = path.getDirectory(filename)
		local ok, err = os.mkdir(dir)
		if not ok then
			error(err, 0)
		end
	end
	return _io_open(filename, mode)
end


return io
