premake.xcode4 = {}

local xcode4 = premake.xcode4

function xcode4.workspace_head()
	_p('<?xml version="1.0" encoding="UTF-8"?>')
	_p('<Workspace')
		_p(1,'version = "1.0">')

end

function xcode4.workspace_tail()
	_p('</Workspace>')
end

function xcode4.workspace_file_ref(prj)

		local projpath = path.getrelative(prj.solution.location, prj.location)
		if projpath == '.' then projpath = '' 
		else projpath = projpath ..'/' 
		end
		_p(1,'<FileRef')
			_p(2,'location = "group:%s">',projpath .. prj.name .. '.xcodeproj')
		_p(1,'</FileRef>')
end

function xcode4.workspace_generate(sln)
	premake.xcode.preparesolution(sln)

	xcode4.workspace_head()

	for prj in premake.solution.eachproject(sln) do
		xcode4.workspace_file_ref(prj)
	end
	
	xcode4.workspace_tail()
end



