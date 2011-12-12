solution "MySolution"

	configurations { 
		"Debug", 
		"Deployment", 
		"Profiling", 
		"Release" 
	}

	platforms {
		"Win32 Static SCRT",
		"Win32 Static DCRT",
		"Win32 DLL",
		"Win64 Static SCRT",
		"Win64 Static DCRT",
		"Win64 DLL",
		"PS3 PPU GCC",
		"PS3 PPU SN",
		"PS3 SPU GCC",
		"PS3 SPU SN"
	}


--
-- Map the platforms to their underlying architectures.
--
	
	configuration { "Win32 *" }
		architecture "x32"
		os "windows"
		
 	configuration { "Win64 *" }
		architecture "x64"
		os "windows"

	configuration { "* PPU *" }
		architecture "ps3ppu"
		
	configuration { "* SPU *" }
		architecture "ps3spu"
	
	configuration { "* GCC" }
		compiler "gcc"
		
	configuration { "* SN" }
		compiler "sn"
