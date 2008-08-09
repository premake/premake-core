/**
 * \file   make_project.h
 * \brief  Makefile project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_PROJECT_H)
#define PREMAKE_MAKE_PROJECT_H

#include "objects/session.h"

int gmake_project_shell_detect(Project prj, Stream strm);

int make_project_clean_rules(Project prj, Stream strm);
int make_project_config_conditional(Project prj, Stream strm);
int make_project_config_cflags(Project prj, Stream strm);
int make_project_config_cppflags(Project prj, Stream strm);
int make_project_config_cxxflags(Project prj, Stream strm);
int make_project_config_end(Project prj, Stream strm);
int make_project_config_lddeps(Project prj, Stream strm);
int make_project_config_ldflags(Project prj, Stream strm);
int make_project_config_objdir(Project prj, Stream strm);
int make_project_config_outdir(Project prj, Stream strm);
int make_project_config_outfile(Project prj, Stream strm);
int make_project_config_resflags(Project prj, Stream strm);
int make_project_create(Project prj, Stream strm);
int make_project_include_dependencies(Project prj, Stream strm);
int make_project_mkdir_rules(Project prj, Stream strm);
int make_project_objects(Project prj, Stream strm);
int make_project_phony_rule(Project prj, Stream strm);
int make_project_resources(Project prj, Stream strm);
int make_project_signature(Project prj, Stream strm);
int make_project_source_rules(Project prj, Stream strm);
int make_project_target(Project prj, Stream strm);

#endif
