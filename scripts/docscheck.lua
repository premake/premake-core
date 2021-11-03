---
-- Validate documentation for Premkake APIs.
---

	local count = 0
	for k,v in pairs(premake.field._loweredList) do
		local docfilepath = "../website/docs/" .. k .. ".md"
		local exists = os.isfile(docfilepath)
		if exists then
			local docfile = io.open(docfilepath, "r")
			local text = docfile:read("*all")
			docfile:close()
			-- Verify that every value is listed
			if type(v.allowed) == "table" then
				for _,value in ipairs(v.allowed) do
					if type(value) == "string" and not string.find(text, value, 1, true) then
						count = count + 1
						print(k .. " missing value `" .. value .. "`")
					end
				end
			end
		else
			print("Missing documentation file for: ", k)
			count = count + 1
		end
	end
	os.exit(count)