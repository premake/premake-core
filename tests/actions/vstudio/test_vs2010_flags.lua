
T.vs2010_flags = { }
local vs10_flags = T.vs2010_flags
local sln, prj

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
	local buffer = io.endcapture()
	return buffer
end


function vs10_flags.sseSet()
	flags  {"EnableSSE"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>')
end

function vs10_flags.sse2Set()
	flags  {"EnableSSE2"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>')
end

function vs10_flags.extraWarningNotSet_warningLevelIsThree()
	local buffer = get_buffer()
	test.string_contains(buffer,'<WarningLevel>Level3</WarningLevel>')
end

function vs10_flags.extraWarning_warningLevelIsFour()
	flags  {"ExtraWarnings"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<WarningLevel>Level4</WarningLevel>')
end

function vs10_flags.extraWarning_treatWarningsAsError_setToTrue()
	flags  {"FatalWarnings"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<TreatWarningAsError>true</TreatWarningAsError>')
end

function vs10_flags.floatFast_floatingPointModel_setToFast()
	flags  {"FloatFast"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<FloatingPointModel>Fast</FloatingPointModel>')
end

function vs10_flags.floatStrict_floatingPointModel_setToStrict()
	flags  {"FloatStrict"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<FloatingPointModel>Strict</FloatingPointModel>')
end

function vs10_flags.nativeWideChar_TreatWChar_tAsBuiltInType_setToTrue()
	flags  {"NativeWChar"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>')
end

function vs10_flags.nativeWideChar_TreatWChar_tAsBuiltInType_setToFalse()
	flags  {"NoNativeWChar"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>')
end

function vs10_flags.noExceptions_exceptionHandling_setToFalse()
	flags  {"NoExceptions"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<ExceptionHandling>false</ExceptionHandling>')
end

function vs10_flags.structuredExceptions_exceptionHandling_setToAsync()
	flags  {"SEH"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<ExceptionHandling>Async</ExceptionHandling>')
end

function vs10_flags.noFramePointer_omitFramePointers_setToTrue()
	flags  {"NoFramePointer"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<OmitFramePointers>true</OmitFramePointers>')
end


function vs10_flags.noRTTI_runtimeTypeInfo_setToFalse()
	flags  {"NoRTTI"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
end

function vs10_flags.optimizeSize_optimization_setToMinSpace()
	flags  {"OptimizeSize"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>MinSpace</Optimization>')
end

function vs10_flags.optimizeSpeed_optimization_setToMaxSpeed()
	flags  {"OptimizeSpeed"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>MaxSpeed</Optimization>')
end
function vs10_flags.optimizeSpeed_optimization_setToMaxSpeed()
	flags  {"Optimize"}
		
	local buffer = get_buffer()
	test.string_contains(buffer,'<Optimization>Full</Optimization>')
end


local debug_string = "Symbols"
local release_string = "Optimize"
function vs10_flags.debugHasNoStaticRuntime_runtimeLibrary_setToMultiThreadedDebugDLL()
	flags {debug_string}
	local buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>')
end

function vs10_flags.debugAndStaticRuntime_runtimeLibrary_setToMultiThreadedDebug()
	flags {debug_string,"StaticRuntime"}
	local buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>')
end

function vs10_flags.releaseHasNoStaticRuntime_runtimeLibrary_setToMultiThreadedDLL()
	flags {release_string}
	local buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>')
end

function vs10_flags.releaseAndStaticRuntime_runtimeLibrary_setToMultiThreaded()
	flags {release_string,"StaticRuntime"}
	local buffer = get_buffer()
	test.string_contains(buffer,'<RuntimeLibrary>MultiThreaded</RuntimeLibrary>')
end

function vs10_flags.noCharacterSetDefine_characterSet_setToMultiByte()
	local buffer = get_buffer()
	test.string_contains(buffer,'<CharacterSet>MultiByte</CharacterSet>')
end

function vs10_flags.unicode_characterSet_setToUnicode()
	flags {"Unicode"}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<CharacterSet>Unicode</CharacterSet>')
end



function vs10_flags.debugAndNoMinimalRebuildAndSymbols_minimalRebuild_setToFalse()
	flags {debug_string,"NoMinimalRebuild"}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<MinimalRebuild>false</MinimalRebuild>')
end

function vs10_flags.debugYetNotMinimalRebuild_minimalRebuild_setToTrue()
	flags {debug_string}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<MinimalRebuild>true</MinimalRebuild>')
end

function vs10_flags.release_minimalRebuild_setToFalse()
	flags {release_string}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<MinimalRebuild>false</MinimalRebuild>')
end

function vs10_flags.mfc_useOfMfc_setToStatic()
    flags{"MFC"}
    
    local buffer = get_buffer()
    test.string_contains(buffer,'<UseOfMfc>Dynamic</UseOfMfc>')
end

function vs10_flags.Symbols_DebugInformationFormat_setToEditAndContinue()
	flags{"Symbols"}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat>EditAndContinue</DebugInformationFormat>')
end

function vs10_flags.symbolsAndNoEditAndContinue_DebugInformationFormat_setToProgramDatabase()
	flags{"Symbols","NoEditAndContinue"}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>')
end

function vs10_flags.symbolsAndRelease_DebugInformationFormat_setToProgramDatabase()
	flags{"Symbols",release_string}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>')
end
function vs10_flags.noSymbols_DebugInformationFormat_blockIsEmpty()
	local buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat></DebugInformationFormat>')
end

function vs10_flags.symbols_64BitBuild_DebugInformationFormat_setToOldStyle()
	flags{"Symbols"}
	platforms{"x64"}
	local buffer = get_buffer()
	test.string_contains(buffer,'<DebugInformationFormat>OldStyle</DebugInformationFormat>')
end

function vs10_flags.noManifest_GenerateManifest_setToFalse()
	flags{"NoManifest"}
	
	local buffer = get_buffer()
	test.string_contains(buffer,'<GenerateManifest Condition="\'%$%(Configuration%)|%$%(Platform%)\'==\'Debug|Win32\'">false</GenerateManifest>')
end

function vs10_flags.noSymbols_bufferDoesNotContainprogramDataBaseFile()
	local buffer = get_buffer()
	test.string_does_not_contain(buffer,'<Link>.*<ProgramDataBaseFileName>.*</Link>')
end
function vs10_flags.symbols_bufferContainsprogramDataBaseFile()
	flags{"Symbols"}
	local buffer = get_buffer()
	test.string_contains(buffer,'<Link>.*<ProgramDataBaseFileName>%$%(OutDir%)MyProject%.pdb</ProgramDataBaseFileName>.*</Link>')
end



