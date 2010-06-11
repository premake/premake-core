
T.vs2010_flags = { }
local vs10_flags = T.vs2010_flags
local sln, prj


--[[
function vs10_flags.setup()end
function vs10_flags.nothing() end
--]]

function vs10_flags.setup()
	_ACTION = "vs2010"

	sln = solution "MySolution"
	configurations { "Debug" }
	platforms {}
	
	prj = project "MyProject"
	language "C++"
	kind "ConsoleApp"
	uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	includedirs{"foo/bar"}	
end

local function get_buffer()
	io.capture()
	premake.buildconfigs()
	sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
	premake.vs2010_vcxproj(prj)
	buffer = io.endcapture()
	return buffer
end


function vs10_flags.sseSet()
	flags  {"EnableSSE"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>')
end

function vs10_flags.sse2Set()
	flags  {"EnableSSE2"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>')
end

function vs10_flags.extraWarningNotSet_warningLevelIsThree()
	buffer = get_buffer()
	test.string_contains(buffer,'<WarningLevel>Level3</WarningLevel>')
end

function vs10_flags.extraWarning_warningLevelIsFour()
	flags  {"ExtraWarnings"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<WarningLevel>Level4</WarningLevel>')
end

function vs10_flags.extraWarning_treatWarningsAsError_setToTrue()
	flags  {"FatalWarnings"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<TreatWarningAsError>true</TreatWarningAsError>')
end

function vs10_flags.floatFast_floatingPointModel_setToFast()
	flags  {"FloatFast"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<FloatingPointModel>Fast</FloatingPointModel>')
end

function vs10_flags.floatStrict_floatingPointModel_setToStrict()
	flags  {"FloatStrict"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<FloatingPointModel>Strict</FloatingPointModel>')
end

function vs10_flags.nativeWideChar_TreatWChar_tAsBuiltInType_setToTrue()
	flags  {"NativeWChar"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>')
end

function vs10_flags.nativeWideChar_TreatWChar_tAsBuiltInType_setToFalse()
	flags  {"NoNativeWChar"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>')
end

function vs10_flags.noExceptions_exceptionHandling_setToFalse()
	flags  {"NoExceptions"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<ExceptionHandling>false</ExceptionHandling>')
end

function vs10_flags.structuredExceptions_exceptionHandling_setToAsync()
	flags  {"SEH"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<ExceptionHandling>Async</ExceptionHandling>')
end

function vs10_flags.noFramePointer_omitFramePointers_setToTrue()
	flags  {"NoFramePointer"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<OmitFramePointers>true</OmitFramePointers>')
end


function vs10_flags.noRTTI_runtimeTypeInfo_setToFalse()
	flags  {"NoRTTI"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
end

function vs10_flags.optimizeSize_optimization_setToMinSpace()
	flags  {"OptimizeSize"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>MinSpace</Optimization>')
end

function vs10_flags.optimizeSpeed_optimization_setToMaxSpeed()
	flags  {"OptimizeSpeed"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>MaxSpeed</Optimization>')
end
function vs10_flags.optimizeSpeed_optimization_setToMaxSpeed()
	flags  {"Optimize"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>Full</Optimization>')
end

function vs10_flags.noStaticRuntime_runtimeLibrary_setToMultiThreadedDLL()		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>')
end

--[[
function vs10_flags.symbols_runtimeLibrary_setToMultiThreadedDebugDLL()
	flags  {"Symbols"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>')
end
--]]

function vs10_flags.noStaticRuntimeYetSymbols_runtimeLibrary_setToMultiThreadedDebugDLL()
	flags  {"Symbols"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>')
end

function vs10_flags.staticRuntime_runtimeLibrary_setToMultiThreaded()
	flags  {"StaticRuntime"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreaded</RuntimeLibrary>')
end

function vs10_flags.staticRuntimeAndSymbols_runtimeLibrary_setToMultiThreadedDebug()
	flags  {"StaticRuntime","Symbols"}
		
	buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>')
end

function vs10_flags.noCharacterSetDefine_characterSet_setToMultiByte()
	buffer = get_buffer()
	test.string_contains(buffer,'<CharacterSet>MultiByte</CharacterSet>')
end

function vs10_flags.unicode_characterSet_setToUnicode()
	flags {"Unicode"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<CharacterSet>Unicode</CharacterSet>')
end


function vs10_flags.noMinimalRebuildYetNotSymbols_minimalRebuild_isNotFound()
	flags {"NoMinimalRebuild"}
	
	buffer = get_buffer()
	test.string_does_not_contain(buffer,'MinimalRebuild')
end

function vs10_flags.noMinimalRebuildAndSymbols_minimalRebuild_setToFalse()
	flags {"NoMinimalRebuild","Symbols"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<MinimalRebuild>false</MinimalRebuild>')
end

function vs10_flags.symbolsSetYetNotMinimalRebuild_minimalRebuild_setToTrue()
	flags {"Symbols"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<MinimalRebuild>true</MinimalRebuild>')
end

--this generates an error: invalid value 'MFC'
--[[
function vs10_flags.mfc_useOfMfc_setToStatic()
    flags{"MFC"}
    
    buffer = get_buffer()
    --test.string_contains(buffer,'<UseOfMfc>Static</UseOfMfc>')
end
--]]

function vs10_flags.Symbols_DebugInformationFormat_setToEditAndContinue()
	flags{"Symbols"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat>EditAndContinue</DebugInformationFormat>')
end

function vs10_flags.symbolsAndNoEditAndContinue_DebugInformationFormat_isAnEmptyBlock()
	flags{"Symbols","NoEditAndContinue"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat></DebugInformationFormat>')
end

function vs10_flags.noManifest_GenerateManifest_setToFalse()
	flags{"NoManifest"}
	
	buffer = get_buffer()
	test.string_contains(buffer,'<GenerateManifest Condition="\'%$%(Configuration%)|%$%(Platform%)\'==\'Debug|Win32\'">false</GenerateManifest>')
end

--[[
this causes a problem when a project is updated with the command line tool
yet it is here until the correct course of action is found
--]]
function vs10_flags.programDataBaseFile()
	buffer = get_buffer()
	test.string_contains(buffer,'<ProgramDataBaseFileName>%$%(OutDir%)MyProject%.pdb</ProgramDataBaseFileName>')
end



