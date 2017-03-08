project "curl-lib"
	language    "C"
	kind        "StaticLib"
	includedirs { "include", "lib", "../mbedtls/include/" }
	defines     { "BUILDING_LIBCURL", "CURL_STATICLIB", "HTTP_ONLY" }
	warnings    "off"

	if not _OPTIONS["no-zlib"] then
		defines     { 'USE_ZLIB' }
		includedirs { '../zlib' }
	end

	files
	{
		"**.h",
		"**.c"
	}
	
	filter { "system:windows" }
		defines { "USE_SCHANNEL", "USE_WINDOWS_SSPI" }
	
	filter { "system:not windows" }
		defines { "USE_MBEDTLS" }

	filter { "system:linux" }
		defines { "CURL_HIDDEN_SYMBOLS" }

		-- find the location of the ca bundle
		local ca = nil
		for _, f in ipairs {
			"/etc/ssl/certs/ca-certificates.crt",
			"/etc/pki/tls/certs/ca-bundle.crt",
			"/usr/share/ssl/certs/ca-bundle.crt",
			"/usr/local/share/certs/ca-root.crt",
			"/etc/ssl/cert.pem" } do
			if os.isfile(f) then
				ca = f
				break
			end
		end
		if ca then
			defines { 'CURL_CA_BUNDLE="' .. ca .. '"' }
		end
