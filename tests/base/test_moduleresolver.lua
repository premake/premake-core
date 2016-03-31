--
-- tests/base/test_moduleresolver.lua
-- Test the module resolver.
--
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

    local suite = test.declare("moduleresolver")

    local moduleresolver = premake.moduleresolver
    
    local _getcwd = os.getcwd
    local _isfile = os.isfile
    
    function suite.teardown()
        os.getcwd = _getcwd
        os.isfile = _isfile
	end
    
--
-- isModulePath should return true when it contains slashes; otherwise, false.
--
    
    function suite.isModulePath_ReturnTrue_OnLeftSlash()
		test.istrue(moduleresolver.isModulePath("/foo"))
	end
    
    function suite.isModulePath_ReturnTrue_OnRightSlash()
		test.istrue(moduleresolver.isModulePath("foo\\"))
	end
    
    function suite.isModulePath_ReturnFalse_OnFilenameWithoutSlashes()
		test.isfalse(moduleresolver.isModulePath("foo"))
	end
    
    function suite.isModulePath_ReturnFalse_OnFilenameWithExtButWithoutSlashes()
		test.isfalse(moduleresolver.isModulePath("foo.lua"))
	end
    
--
-- getDefaultModuleDirectory should return the default module's directory.
--

    function suite.getDefaultModuleDirectory_ReturnDefaultDirectoryName()
        test.isequal(".premake", moduleresolver.getDefaultModuleDirectory())
	end
    
--
-- getDefaultModulePath should return the default module's path.
--

    function suite.getDefaultModulePath_ReturnDefaultDirectoryName_OnPathWithoutExtension()
        test.isequal(".premake/foo.lua", moduleresolver.getDefaultModulePath("foo"))
	end
    
    function suite.getDefaultModulePath_ReturnDefaultDirectoryName_OnPathWithExtension()
        test.isequal(".premake/foo.lua", moduleresolver.getDefaultModulePath("foo.lua"))
	end
    
--
-- searchModuleFile should return with a valid path; otherwise, when it is invalid it should return "." 
--

    function suite.searchModuleFile_ReturnWithValidPath_OnTop()
        local expectedModuleFile = "d:/foo/bar/baz/.premake/foo.lua"
        
        os.isfile = function(file)
            return file == expectedModuleFile
        end
        
        local actualModuleFile, trackedPaths = moduleresolver.searchModuleFile("d:/foo/bar/baz", ".premake/foo.lua")
        
        test.isequal(expectedModuleFile, actualModuleFile)
	end
    
    function suite.searchModuleFile_ReturnWithValidPath_OnBottom()
        local expectedModuleFile = "d:/.premake/foo.lua"
        
        os.isfile = function(file)
            return file == expectedModuleFile
        end
        
        local actualModuleFile, trackedPaths = moduleresolver.searchModuleFile("d:/foo/bar/baz", ".premake/foo.lua")

        test.isequal(expectedModuleFile, actualModuleFile) 
	end
    
    function suite.searchModuleFile_ReturnWithInvalidPath()
        os.isfile = function(file)
            return false
        end
        
        local moduleFile, trackedPaths = moduleresolver.searchModuleFile("d:/foo/bar/baz", ".premake/foo.lua")
        
        test.isnil(moduleFile)
	end
    
--
-- resolveModule should either return with the path that was provided by the user or the searched path; otherwise, it should fail-fast.
--

    function suite.resolveModule_ReturnWithUserProvidedPath()
        test.isequal("bar/foo", moduleresolver.resolveModule("bar/foo"))
	end
    
    function suite.resolveModule_ReturnWithNoExtension()
        test.isequal("bar/foo", moduleresolver.resolveModule("bar/foo.lua"))
	end
    
    function suite.resolveModule_ReturnWithSearchResults()
        os.getcwd = function()
            return "d:/foo/bar/baz"
        end
        
        os.isfile = function(file)
            return file == "d:/foo/.premake/foo.lua"
        end

        test.isequal("../../.premake/foo", moduleresolver.resolveModule("foo")) 
	end
    
    function suite.resolveModule_FailWithError_OnNoSearchResults()
        os.getcwd = function()
            return "d:/foo/bar/baz"
        end

        os.isfile = function(file)
            return false
        end

        local success = pcall(moduleresolver.resolveModule, "foo")
        
        test.isfalse(success) 
	end
    
--
-- require tests
--

    function suite.require_FailWithError_OnSuccessfulModuleResolution()
        os.getcwd = function()
            return "d:/foo/bar/baz"
        end

        os.isfile = function(file)
            return true
        end

        local success, err = pcall(require, "foobaz")
        
        test.istrue(not success and string.contains(err, "module '.premake/foobaz' not found:") 
                                and not string.contains(err, "module 'foobaz' not resolved:")) 
	end
    
    function suite.require_FailWithError_OnFailedModuleResolution()
        os.getcwd = function()
            return "d:/foo/bar/baz"
        end

        os.isfile = function(file)
            return false
        end

        local success, err = pcall(require, "foobaz")
        
        test.istrue(not success and string.contains(err, "module 'foobaz' not found") 
                                and string.contains(err, "module 'foobaz' not resolved:")) 
	end


    