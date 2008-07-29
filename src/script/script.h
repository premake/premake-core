/**
 * \file   script.h
 * \brief  The project scripting engine.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 *
 * \defgroup script Scripting Engine
 *
 * The project scripting engine.
 *
 * @{
 */
#if !defined(PREMAKE_SCRIPT_H)
#define PREMAKE_SCRIPT_H

#include "base/array.h"

DECLARE_CLASS(Script)

Script      script_create(void);
void        script_destroy(Script script);
const char* script_get_action(Script script);
int         script_is_match(Script script, const char* str, const char* pattern);
const char* script_run_file(Script script, const char* filename);
const char* script_run_string(Script script, const char* code);
void        script_set_action(Script script, const char* action);
int         script_tests(void);
int         script_unload(Script script, Array slns);

#endif
/** @} */
