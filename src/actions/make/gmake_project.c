/**
 * \file   gmake_project.c
 * \brief  GNU makefile project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "make_project.h"


/**
 * Write the shell detection block, which is used while building on Windows in
 * order to detect the enclosing shell type: MS-DOS, Cygwin, or MinGW. The shell
 * determines how directories and files should be created and removed.
 *
 * While the detection in important only on Windows, I write for all platforms.
 * This simplifies the code generation, and makes portable makefiles possible 
 * (even though most will have platform-specific bits in them).
 */
int gmake_project_shell_detect(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "SHELLTYPE := msdos");
	z |= stream_writeline(strm, "ifeq (,$(ComSpec)$(COMSPEC))");
	z |= stream_writeline(strm, "   SHELLTYPE := posix");
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "ifeq (/bin,$(findstring /bin,$(SHELL)))");
	z |= stream_writeline(strm, "   SHELLTYPE := posix");
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "");
	z |= stream_writeline(strm, "ifeq (posix,$(SHELLTYPE))");
	z |= stream_writeline(strm, "   MKDIR   := mkdir -p");
	z |= stream_writeline(strm, "   PATHSEP := /");
	z |= stream_writeline(strm, "else");
	z |= stream_writeline(strm, "   MKDIR   := mkdir");
	z |= stream_writeline(strm, "   PATHSEP := \\\\");
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "");
	z |= stream_writeline(strm, "SYS_OUTDIR  := $(subst /,$(PATHSEP),$(OUTDIR))");
	z |= stream_writeline(strm, "SYS_OUTFILE := $(subst /,$(PATHSEP),$(OUTFILE))");
	z |= stream_writeline(strm, "SYS_OBJDIR  := $(subst /,$(PATHSEP),$(OBJDIR))");
	z |= stream_writeline(strm, "");
	return z;
}

