/**
 * \file   make_project.c
 * \brief  Makefile project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "actions/make/make.h"
#include "actions/make/make_project.h"
#include "base/error.h"
#include "base/path.h"


/**
 * Write the rules to clean up output files on a `make clean`.
 */
int make_project_clean_rules(Project prj, Stream strm)
{
	int z = OKAY;
	z |= stream_writeline(strm, "clean:");
	z |= stream_writeline(strm, "\t@echo Cleaning %s", project_get_name(prj));
	z |= stream_writeline(strm, "ifeq (posix, $(SHELLTYPE))");
	z |= stream_writeline(strm, "\t@rm -f  $(SYS_OUTFILE)");
	z |= stream_writeline(strm, "\t@rm -rf $(SYS_OBJDIR)");
	z |= stream_writeline(strm, "else");
	z |= stream_writeline(strm, "\t@if exist $(SYS_OUTFILE) del $(SYS_OUTFILE)");
	z |= stream_writeline(strm, "\t@if exist $(SYS_OBJDIR) rmdir /s /q $(SYS_OBJDIR)");
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "");
	return OKAY;
}


/**
 * Write the opening conditional for a configuration block.
 */
int make_project_config_conditional(Project prj, Stream strm)
{
	const char* cfg_name = project_get_config(prj);
	return stream_writeline(strm, "ifeq ($(CONFIG),%s)", cfg_name);
}


/**
 * Write the CFLAGS configuration variable.
 */
int make_project_config_cflags(Project prj, Stream strm)
{
	int z = OKAY;

	z |= stream_write(strm, "   CFLAGS   += $(CPPFLAGS) $(ARCHFLAGS)");

	/* debugging symbols */
	if (project_has_flag(prj, "Symbols"))
	{
		z |= stream_write(strm, " -g");
	}

	/* optimizations */
	if (project_has_flag(prj, "Optimize"))
	{
		z |= stream_write(strm, " -O2");
	}
	else if (project_has_flag(prj, "OptimizeSize"))
	{
		z |= stream_write(strm, " -Os");
	}
	else if (project_has_flag(prj, "OptimizeSpeed"))
	{
		z |= stream_write(strm, " -O3");
	}

	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the CPPFLAGS configuration variable.
 */
int make_project_config_cppflags(Project prj, Stream strm)
{
	int z = OKAY;
	Strings values = project_get_config_values(prj, BlockDefines);	
	z |= stream_write(strm, "   CPPFLAGS += -MMD");
	z |= stream_write_strings(strm, values, "", " -D \"", "\"", "", "", NULL);
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the CXXFLAGS configuration variable.
 */
int make_project_config_cxxflags(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "   CXXFLAGS += $(CFLAGS)");
}


/**
 * Write the opening conditional for a configuration block.
 */
int make_project_config_end(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "endif");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the LDDEPS configuration variable.
 */
int make_project_config_lddeps(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "   LDDEPS   :=");
}


/**
 * Write the LDFLAGS configuration variable.
 */
int make_project_config_ldflags(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "   LDFLAGS  +=");
}


/**
 * Write the OBJDIR configuration variable.
 */
int make_project_config_objdir(Project prj, Stream strm)
{
	const char* cfg_name = project_get_config(prj);
	return stream_writeline(strm, "   OBJDIR   := obj/%s", make_escape(cfg_name));
}


/**
 * Write the OUTDIR configuration variable.
 */
int make_project_config_outdir(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "   OUTDIR   := .");
}


/**
 * Write the OUTFILE configuration variable.
 */
int make_project_config_outfile(Project prj, Stream strm)
{
	const char* outfile = project_get_outfile(prj);
	return stream_writeline(strm, "   OUTFILE  := $(OUTDIR)/%s", make_escape(outfile));
}


/**
 * Write the RESFLAGS configuration variable.
 */
int make_project_config_resflags(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "   RESFLAGS +=");
}


/**
 * Create a new output stream for a project , and make it active for subsequent writes.
 */
int make_project_create(Project prj, Stream strm)
{
	/* create the makefile */
	const char* filename = make_get_project_makefile(prj);
	strm = stream_create_file(filename);
	if (!strm)
	{
		return !OKAY;
	}

	/* make the stream active for the functions that come after */
	session_set_active_stream(project_get_session(prj), strm);
	return OKAY;
}


/**
 * Include the auto-generated dependencies into the project makefile.
 */
int make_project_include_dependencies(Project prj, Stream strm)
{
	UNUSED(prj);
	return stream_writeline(strm, "-include $(OBJECTS:%%.o=%%.d)");
}


/**
 * Write the rules to create the output and object directories.
 */
int make_project_mkdir_rules(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "$(OUTDIR):");
	z |= stream_writeline(strm, "\t@echo Creating $(OUTDIR)");
	z |= stream_writeline(strm, "\t@$(MKDIR) $(SYS_OUTDIR)");
	z |= stream_writeline(strm, "");
	z |= stream_writeline(strm, "$(OBJDIR):");
	z |= stream_writeline(strm, "\t@echo Creating $(OBJDIR)");
	z |= stream_writeline(strm, "\t@$(MKDIR) $(SYS_OBJDIR)");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the OBJECTS project variable.
 */
int make_project_objects(Project prj, Stream strm)
{
	Strings files;
	int i, n, z;

	z  = stream_writeline(strm, "OBJECTS := \\");

	files = project_get_files(prj);
	n = strings_size(files);
	for (i = 0; i < n; ++i)
	{
		const char* filename = strings_item(files, i);
		if (path_is_cpp_source(filename))
		{
			const char* obj_name = make_get_obj_filename(filename);
			z |= stream_writeline(strm, "\t%s \\", make_escape(obj_name));
		}
	}

	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the .PHONY rule for a project.
 */
int make_project_phony_rule(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, ".PHONY: clean");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the RESOURCES project variable.
 */
int make_project_resources(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "RESOURCES := \\");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write the project makefile signature.
 */
int make_project_signature(Project prj, Stream strm)
{
	int z = OKAY;
	UNUSED(prj);
	z |= stream_writeline(strm, "# GNU Makefile autogenerated by Premake");
	z |= stream_writeline(strm, "");
	return z;
}


/**
 * Write makefile rules for each source code file.
 */
int make_project_source_rules(Project prj, Stream strm)
{
	Strings files;
	int i, n, z = OKAY;

	files = project_get_files(prj);
	n = strings_size(files);
	for (i = 0; i < n; ++i)
	{
		const char* filename = make_escape(strings_item(files, i));
		if (path_is_cpp_source(filename))
		{
			const char* obj_name = make_get_obj_filename(filename);
			z |= stream_writeline(strm, "%s: %s", obj_name, filename);
			z |= stream_writeline(strm, "\t@echo $(notdir $<)");
			z |= stream_writeline(strm, "\t@$(CXX) $(CXXFLAGS) -o $@ -c $<");
			z |= stream_writeline(strm, "");
		}
	}

	return z;
}


/**
 * Write the project output target rule.
 */
int make_project_target(Project prj, Stream strm)
{
	int z = OKAY;
	z |= stream_writeline(strm, "$(OUTFILE): $(OUTDIR) $(OBJDIR) $(OBJECTS) $(LDDEPS) $(RESOURCES)");
	z |= stream_writeline(strm, "\t@echo Linking %s", project_get_name(prj));
	z |= stream_writeline(strm, "\t@$(CXX) -o $@ $(LDFLAGS) $(ARCHFLAGS) $(OBJECTS) $(RESOURCES)");
	z |= stream_writeline(strm, "");
	return z;
}
