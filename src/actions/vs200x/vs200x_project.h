/**
 * \file   vs200x_project.h
 * \brief  Visual Studio 200x project generation functions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_VS200X_PROJECT_H)
#define PREMAKE_VS200X_PROJECT_H

int vs200x_project_config_element(Project prj, Stream strm);
int vs200x_project_config_end(Project prj, Stream strm);
int vs200x_project_create(Project prj, Stream strm);
int vs200x_project_element(Project prj, Stream strm);
int vs200x_project_encoding(Project prj, Stream strm);
int vs200x_project_file(Project prj, Stream strm, const char* filename, int state);
int vs200x_project_files(Project prj, Stream strm);
int vs200x_project_globals(Project prj, Stream strm);
int vs200x_project_platforms(Project prj, Stream strm);
int vs200x_project_references(Project prj, Stream strm);
int vs200x_project_tool_files(Project prj, Stream strm);
int vs200x_project_vc_alink_tool(Project prj, Stream strm);
int vs200x_project_vc_app_verifier_tool(Project prj, Stream strm);
int vs200x_project_vc_bsc_make_tool(Project prj, Stream strm);
int vs200x_project_vc_cl_compiler_tool(Project prj, Stream strm);
int vs200x_project_vc_custom_build_tool(Project prj, Stream strm);
int vs200x_project_vc_fx_cop_tool(Project prj, Stream strm);
int vs200x_project_vc_midl_tool(Project prj, Stream strm);
int vs200x_project_vc_linker_tool(Project prj, Stream strm);
int vs200x_project_vc_managed_resource_compiler_tool(Project prj, Stream strm);
int vs200x_project_vc_manifest_tool(Project prj, Stream strm);
int vs200x_project_vc_pre_build_event_tool(Project prj, Stream strm);
int vs200x_project_vc_pre_link_event_tool(Project prj, Stream strm);
int vs200x_project_vc_post_build_event_tool(Project prj, Stream strm);
int vs200x_project_vc_resource_compiler_tool(Project prj, Stream strm);
int vs200x_project_vc_web_deployment_tool(Project prj, Stream strm);
int vs200x_project_vc_web_service_proxy_generator_tool(Project prj, Stream strm);
int vs200x_project_vc_xdc_make_tool(Project prj, Stream strm);
int vs200x_project_vc_xml_data_generator_tool(Project prj, Stream strm);

#endif
