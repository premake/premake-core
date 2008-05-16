/**
 * \file   path_tests.cpp
 * \brief  Path handling automated tests.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "testing/testing.h"
extern "C" {
#include "base/path.h"
#include "base/cstr.h"
#include "base/dir.h"
#include "platform/platform.h"
}

SUITE(base)
{
	/**************************************************************************
	 * path_absolute() tests
	 **************************************************************************/

	TEST(PathAbsolute_ReturnsCorrectPath_OnMissingSubdir)
	{
		char* cwd = dir_get_current();
		strcat(cwd, "/a/b/c");
		char* result = path_absolute("a/b/c");
		CHECK_EQUAL(cwd, result);
	}


	/**************************************************************************
	 * path_assemble() tests
	 **************************************************************************/

	TEST(PathAssemble_ReturnsAssembledPath_OnValidParts)
	{
		char* result = path_assemble("directory", "filename", ".ext");
		CHECK_EQUAL("directory/filename.ext", result);
	}

	TEST(PathAssemble_ReturnsAssembledPath_OnNoDirectory)
	{
		char* result = path_assemble("", "filename", ".ext");
		CHECK_EQUAL("filename.ext", result);
	}


	/**************************************************************************
	 * path_basename() tests
	 **************************************************************************/

	TEST(PathBaseName_ReturnsBase_OnDirAndExt)
	{
		char* result = path_basename("folder/filename.ext");
		CHECK_EQUAL("filename", result);
	}


	/**************************************************************************
	 * path_directory() tests
	 **************************************************************************/

	TEST(PathDirectory_ReturnsEmptyString_OnNoDirectory)
	{
		char* result = path_directory("filename.ext");
		CHECK_EQUAL("", result);
	}


	TEST(PathDirectory_ReturnsDirectory_OnSingleLevelPath)
	{
		char* result = path_directory("dir0/filename.ext");
		CHECK_EQUAL("dir0", result);
	}


	TEST(PathDirectory_ReturnsDirectory_OnMultiLeveLPath)
	{
		char* result = path_directory("dir0/dir1/dir2/filename.ext");
		CHECK_EQUAL("dir0/dir1/dir2", result);
	}


	/**************************************************************************
	 * path_extension() tests
	 **************************************************************************/

	TEST(PathExt_ReturnsEmptyString_OnNoExtension)
	{
		char* result = path_extension("filename");
		CHECK_EQUAL("", result);
	}

	TEST(PathExt_ReturnsExtension)
	{
		char* result = path_extension("filename.txt");
		CHECK_EQUAL(".txt", result);
	}

	TEST(PathExt_ReturnsLastExtension_OnMultipleDots)
	{
		char* result = path_extension("filename.mod.txt");
		CHECK_EQUAL(".txt", result);
	}


	/**************************************************************************
	 * path_filename() tests
	 **************************************************************************/

	TEST(PathFileName_ReturnsAll_OnNoDirectory)
	{
		char* result = path_filename("filename.ext");
		CHECK_EQUAL("filename.ext", result);
	}

	TEST(PathFileName_ReturnsEmptyString_OnNoName)
	{
		char* result = path_filename("dir0/dir1/");
		CHECK_EQUAL("", result);
	}

	TEST(PathFileName_ReturnsOnlyName_OnFullPath)
	{
		char* result = path_filename("dir0/dir1/filename.ext");
		CHECK_EQUAL("filename.ext", result);
	}


	/**************************************************************************
	 * path_is_absolute() tests
	 **************************************************************************/

	TEST(PathIsAbsolute_ReturnsTrue_OnAbsolutePosixPath)
	{
		CHECK(path_is_absolute("/a/b/c"));
	}


	TEST(PathIsAbsolute_ReturnsTrue_OnAbsoluteWindowsPathWithDrive)
	{
		CHECK(path_is_absolute("c:/a/b/c"));
	}


	TEST(PathIsAbsolute_ReturnsFalse_OnRelativePath)
	{
		CHECK(!path_is_absolute("a/b/c"));
	}


	/**************************************************************************
	 * path_is_absolute() tests
	 **************************************************************************/
		
	TEST(PathIsCpp_ReturnsFalse_OnNotCpp)
	{
		CHECK(!path_is_cpp_source("filename.XXX"));
	}

	TEST(PathIsCpp_ReturnsTrue_OnC)
	{
		CHECK(path_is_cpp_source("filename.c"));
	}
	
	TEST(PathIsCpp_ReturnsTrue_OnCC)
	{
		CHECK(path_is_cpp_source("filename.cc"));
	}

	TEST(PathIsCpp_ReturnsTrue_OnCpp)
	{
		CHECK(path_is_cpp_source("filename.cpp"));
	}
	
	TEST(PathIsCpp_ReturnsTrue_OnCxx)
	{
		CHECK(path_is_cpp_source("filename.cxx"));
	}
	
	TEST(PathIsCpp_ReturnsTrue_OnS)
	{
		CHECK(path_is_cpp_source("filename.s"));
	}
	
	TEST(PathIsCpp_ReturnsTrue_OnUpperCase)
	{
		CHECK(path_is_cpp_source("filename.C"));
	}


	/**************************************************************************
	 * path_join() tests
	 **************************************************************************/

	TEST(PathJoin_ReturnsJoinedPath_OnValidParts)
	{
		char* result = path_join("leading", "trailing");
		CHECK_EQUAL("leading/trailing", result);
	}

	TEST(PathJoin_ReturnsAbsPath_OnAbsUnixPath)
	{
		char* result = path_join("leading", "/trailing");
		CHECK_EQUAL("/trailing", result);
	}

	TEST(PathJoin_ReturnsAbsPath_OnAbsWindowsPath)
	{
		char* result = path_join("leading", "C:/trailing");
		CHECK_EQUAL("C:/trailing", result);
	}


	/**************************************************************************
	 * path_relative() tests
	 **************************************************************************/

	TEST(PathRelative_ReturnsDot_OnMatchingPaths)
	{
		char* result = path_relative("/a/b/c", "/a/b/c");
		CHECK_EQUAL(".", result);
	}


	TEST(PathRelative_ReturnsDoubleDot_OnChildToParent)
	{
		char* result = path_relative("/a/b/c", "/a/b");
		CHECK_EQUAL("..", result);
	}


	TEST(PathRelative_ReturnsDoubleDotPath_OnSiblingToSibling)
	{
		char* result = path_relative("/a/b/c", "/a/b/d");
		CHECK_EQUAL("../d", result);
	}


	TEST(PathRelative_ReturnsChildPath_OnParentToChild)
	{
		char* result = path_relative("/a/b/c", "/a/b/c/d");
		CHECK_EQUAL("d", result);
	}


	/**************************************************************************
	 * path_translate() tests
	 **************************************************************************/

	TEST(PathTranslate_ReturnsTranslatedPath_OnValidPath)
	{
		char* result = path_translate("dir\\dir\\file", "/");
		CHECK_EQUAL("dir/dir/file", result);
	}

	TEST(PathTranslate_ReturnsCorrectSeparator_OnMixedPath)
	{
		char* result = path_translate("dir\\dir/file", NULL);
	#if defined(PLATFORM_WINDOWS)
		CHECK_EQUAL("dir\\dir\\file", result);
	#else
		CHECK_EQUAL("dir/dir/file", result);
	#endif
	}
}
