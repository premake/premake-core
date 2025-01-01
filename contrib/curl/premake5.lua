project "curl-lib"
	language    "C"
	kind        "StaticLib"
	externalincludedirs { "include" }
	includedirs { "lib", "../mbedtls/include" }
	defines     { "BUILDING_LIBCURL", "CURL_STATICLIB", "HTTP_ONLY" }
	warnings    "off"

	files
	{
		"**.h",
		"**.c"
	}

	filter { "options:not zlib-src=none" }
		defines     { 'USE_ZLIB' }

	filter { "options:zlib-src=contrib" }
		includedirs { '../zlib' }

	filter { "system:windows" }
		defines { "USE_SCHANNEL", "USE_WINDOWS_SSPI" }
		links { "crypt32", "bcrypt" }

	filter { "system:macosx" }
		defines { "USE_SECTRANSP" }

	filter { "system:not windows", "system:not macosx" }
		defines { "USE_MBEDTLS" }

	filter { "system:linux or toolset:cosmocc"}
		defines { "_GNU_SOURCE" }

	filter { "system:linux or bsd or solaris or haiku or toolset:cosmocc" }
		defines { "CURL_HIDDEN_SYMBOLS" }

		-- find the location of the ca bundle
		local ca = nil
		for _, f in ipairs {
			"/etc/ssl/certs/ca-certificates.crt",
			"/etc/openssl/certs/ca-certificates.crt",
			"/etc/pki/tls/certs/ca-bundle.crt",
			"/usr/share/ssl/certs/ca-bundle.crt",
			"/usr/local/share/certs/ca-root.crt",
			"/usr/local/share/certs/ca-root-nss.crt",
			"/etc/certs/ca-certificates.crt",
			"/etc/ssl/cert.pem",
			"/etc/ssl/cacert.pem",
			"/boot/system/data/ssl/CARootCertificates.pem" } do
			if os.isfile(f) then
				ca = f
				break
			end
		end
		if ca then
			defines { 'CURL_CA_BUNDLE="' .. ca .. '"', 'CURL_CA_PATH="' .. path.getdirectory(ca) .. '"' }
		end
