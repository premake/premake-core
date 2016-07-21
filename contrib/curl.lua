project "curl-lib"
	language    "C"
	kind        "StaticLib"
	includedirs { "config", "config/curl", "curl/include", "curl/lib" }
	defines     { "HAVE_CONFIG_H", "BUILDING_LIBCURL", "CURL_STATICLIB", "HTTP_ONLY", "CURL_DISABLE_LDAP" }
	warnings    "off"

	files
	{
		"curl/include/**.h",
		"curl/lib/**.h",
		"curl/lib/**.c",
		"config/curl/**.h"
	}

	filter { "system:windows" }
		defines { "WIN32" }
		defines { "USE_SCHANNEL", "USE_WINDOWS_SSPI" }

	filter { "system:linux" }
		defines { "CURL_HIDDEN_SYMBOLS" }

		if os.findlib("ssl") then
			defines { "USE_OPENSSL", "USE_SSLEAY" }

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
		end

	filter { "system:macosx" }
		defines { "USE_DARWINSSL" }
