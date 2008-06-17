/**
 * \file   make_project.h
 * \brief  Makefile project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_MAKE_PROJECT_H)
#define PREMAKE_MAKE_PROJECT_H

#include "session/session.h"

int gmake_project_shell_detect(Session sess, Project prj, Stream strm);

int make_project_clean_rules(Session sess, Project prj, Stream strm);
int make_project_config_conditional(Session sess, Project prj, Stream strm);
int make_project_config_cflags(Session sess, Project prj, Stream strm);
int make_project_config_cppflags(Session sess, Project prj, Stream strm);
int make_project_config_cxxflags(Session sess, Project prj, Stream strm);
int make_project_config_end(Session sess, Project prj, Stream strm);
int make_project_config_lddeps(Session sess, Project prj, Stream strm);
int make_project_config_ldflags(Session sess, Project prj, Stream strm);
int make_project_config_objdir(Session sess, Project prj, Stream strm);
int make_project_config_outdir(Session sess, Project prj, Stream strm);
int make_project_config_outfile(Session sess, Project prj, Stream strm);
int make_project_config_resflags(Session sess, Project prj, Stream strm);
int make_project_create(Session sess, Project prj, Stream strm);
int make_project_include_dependencies(Session sess, Project prj, Stream strm);
int make_project_mkdir_rules(Session sess, Project prj, Stream strm);
int make_project_objects(Session sess, Project prj, Stream strm);
int make_project_phony_rule(Session sess, Project prj, Stream strm);
int make_project_resources(Session sess, Project prj, Stream strm);
int make_project_signature(Session sess, Project prj, Stream strm);
int make_project_source_rules(Session sess, Project prj, Stream strm);
int make_project_target(Session sess, Project prj, Stream strm);

#endif
