--
-- tests/base/test_http.lua
-- Tests the http API
-- Copyright (c) 2016, 2020 Jess Perkins and the Premake project
--

if http ~= nil and http.get ~= nil and _OPTIONS["test-all"] then
	local p = premake

	local suite = test.declare("premake_http")

	local function sleep(n) -- active sleep (in second), as lua doesn't have one
		local clock = os.clock
		local t0 = clock()
		while clock() - t0 <= n do end
	end

	local function safe_http_get(...)
		local max_attempt_count = 5
		local seconds_to_wait = 0.2
		local content, err, responseCode
		for i = 0, max_attempt_count do
			content, err, responseCode = http.get(...)
			if content then
				return content, err, responseCode
			else
				sleep(seconds_to_wait)
			end
		end
		return content, err, responseCode
	end

	function suite.http_get()
		local result, err = safe_http_get("http://httpbingo.org/user-agent")
		if result then
			p.out(result)
			test.capture(
				'{"user-agent": "Premake/' .. _PREMAKE_VERSION .. '"}'
			)
		else
			test.fail(err);
		end
	end

	function suite.https_get()
		-- sslverifypeer = 0, so we can test from within companies like here at Blizzard where all HTTPS traffic goes through
		-- some strange black box that re-signs all traffic with a custom ssl certificate.
		local result, err = safe_http_get("https://httpbingo.org/user-agent", { sslverifypeer = 0 })
		if result then
			p.out(result)
			test.capture(
				'{"user-agent": "Premake/' .. _PREMAKE_VERSION .. '"}'
			)
		else
			test.fail(err);
		end
	end

	function suite.https_get_verify_peer()
		local result, err = safe_http_get("https://httpbingo.org/user-agent")
		if result then
			p.out(result)
			test.capture(
				'{"user-agent": "Premake/' .. _PREMAKE_VERSION .. '"}'
			)
		else
			test.fail(err);
		end
	end

	function suite.http_responsecode()
		local result, err, responseCode = safe_http_get("http://httpbingo.org/status/418")
		test.isequal(418, responseCode)
	end

	-- Disable as httpbin.org returns 404 on this endpoint
	-- See: https://github.com/postmanlabs/httpbin/issues/617

	--[[
	function suite.http_redirect()
		local result, err, responseCode = safe_http_get("http://httpbingo.org/redirect/3")
		if result then
			test.isequal(200, responseCode)
		else
			test.fail(err);
		end
	end
	]]

	function suite.http_headers()
		local result, err, responseCode = safe_http_get("http://httpbingo.org/headers", {
			headers = { 'X-Premake: premake' }
		})

		if result then
			if (not result:find('X-Premake')) then
				test.fail("response doens't contain header")
				test.print(result)
			end
		else
			test.fail(err);
		end
	end

end
