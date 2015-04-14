-- Curl Setup Functions


-- Run configure for curl

function CurlSetup()

	local curlversion="curl-7.41.0"

	includedirs
	{
		"modules/curl/" .. curlversion .. "/include",
		"modules/curl/" .. curlversion .. "/lib",
	}

	files
	{
		"modules/curl/" .. curlversion .. "/lib/**.c",
		"modules/curl/" .. curlversion .. "/lib/**.h",
	}

	defines
	{
		"CURL_STATICLIB",
		"BUILDING_LIBCURL",
		"CURL_HTTP",
	}

	links { "idn" }

	configuration "windows"
		defines { "USE_SCHANNEL", "USE_WINDOWS_SSPI" }
		links { "Ws2_32" }

	configuration "not windows"
		defines { "HAVE_CONFIG_H" }

	local ssl = os.is("macosx") and "--with-darwinssl" or "--with-openssl"
	prebuildcommands 
	{
		'sh -c "if [ ! -f ./modules/curl/' .. curlversion .. '/config.status ]; then '
			.. "cd ./modules/curl/" .. curlversion .. " && ./configure " .. ssl
			.. " --disable-ftp --disable-file"
			.. " --disable-ldap --disable-ldaps --disable-rtsp --disable-dict"
			.. " --disable-telnet --disable-tftp --disable-pop3 --disable-imap"
			.. ' --disable-smtp --disable-gopher; fi"'
	}

	configuration "macosx"
		defines { "USE_DARWINSSL" }
		links { "Security.framework", "z" }

	configuration { "not windows", "not macosx" }
		defines { "USE_SSLEAY", "USE_OPENSSL" }
		links { "ssl", "crypto", "z" }
end

