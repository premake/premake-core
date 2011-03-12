
--
--Windows
--AMD64 or IA64 or x86 according to --http://msdn.microsoft.com/en-us/library/aa384274(VS.85).aspx
--
local function windows_is_64_bit()
--works on 64 bit windows running a 32 bit binary
	local arch = os.getenv("PROCESSOR_ARCHITECTURE")
	if string.find(arch,'AMD64') or string.find(arch,'IA64') then
		--64 bit executable running on 64 bit windows
		return true
 	else 
 		--if running under wow then the above returns X86, so check using this 
 		--function defined in host.c
 		return host.windows_is_64bit_running_under_wow()
 	end
end

local function get_result_of_command(cmd)
	local pipe = io.popen(cmd)
	local result = pipe:read('*a')
	pipe:close()
	return result
end

local function linux_is_64_bit()
--works on 64bit Debian running a 32 bit binary
	local contents= get_result_of_command('uname -m')
	local t64 = 
	{
		'x86_64'
		,'ia64'
		,'amd64'
		,'powerpc64'
		,'sparc64'
	}
	for _,v in ipairs(t64) do
		if contents:find(v) then return true end
	end
	return false
end


local function macosx_is_64_bit()
--works on mac mini 10.6 as well as others
	local contents= get_result_of_command('echo $HOSTTYPE')
	--PPC64 is this correct?
	if string.find(contents,'x86_64') or string.find(contents,'PPC64') then 
		return true
	end
	return false
end

host.is_64bit = function()
	local host_os = _OS

	if host_os == 'linux' or host_os == 'bsd' or host_os == 'solaris' or host_os == 'haiku' then
		--I assume these are correct only tested with 'linux'
		return linux_is_64_bit()
	elseif host_os == 'macosx' then
		return macosx_is_64_bit()
	elseif host_os == 'windows' then
		return windows_is_64_bit()
	else
		error('unknown host platform, please contact premake')
	end
end
