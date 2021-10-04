---
-- Validate documentation for Premkake APIs.
---

	local count = 0
	for k,v in pairs(premake.field._loweredList) do
		local docfilepath = "../website/docs/" .. k .. ".md"
		local exists = os.isfile(docfilepath)
		if not exists then
			print("Missing documentation file for: ", k)
			count = count + 1
		end
	end
	os.exit(count)