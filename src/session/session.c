/**
 * \file   session.c
 * \brief  Context for a program execution session.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "session.h"
#include "script/script.h"
#include "base/array.h"
#include "base/cstr.h"
#include "base/error.h"


DEFINE_CLASS(Session)
{
	Script     script;
	Array      solutions;
	Stream     active_stream;
};


/**
 * Create a new session object.
 * \returns A new session object, or NULL if the scripting engine fails to start.
 */
Session session_create(void)
{
	Session sess;

	/* create an instance of the project scripting engine */
	Script script = script_create();
	if (script == NULL)
	{
		return NULL;
	}

	/* create and return the session object */
	sess = ALLOC_CLASS(Session);
	sess->script = script;
	sess->solutions = array_create();
	sess->active_stream = NULL;
	return sess;
}


/**
 * Destroy a session object and release the associated memory.
 * \param   sess   The session object to destroy.
 */
void session_destroy(Session sess)
{
	int i, n;

	assert(sess);
	
	n = session_num_solutions(sess);
	for (i = 0; i < n; ++i)
	{
		Solution sln = session_get_solution(sess, i);
		solution_destroy(sln);
	}

	script_destroy(sess->script);
	array_destroy(sess->solutions);
	free(sess);
}


/**
 * Adds a new solution to the list of solutions contained by the session.
 * \param   sess    The session object.
 * \param   sln     The new solution to add.
 */
void session_add_solution(Session sess, Solution sln)
{
	assert(sess);
	assert(sln);
	array_add(sess->solutions, sln);
}


/**
 * A bit of black magic: this function acts as a special token for the project handler
 * function list to indicate where configurations should appear. For more details, see
 * the implementation of session_enumerate_objects().
 * \param   sess      The session object.
 * \param   prj       The target project.
 * \param   strm      The currently active output stream.
 * \returns OKAY.
 */
int session_enumerate_configurations(Session sess, Project prj, Stream strm)
{
	UNUSED(sess);
	UNUSED(prj);
	UNUSED(strm);
	return OKAY;
}


/**
 * Iterate the project objects contained by the session and hand them off to handler callbacks.
 * \param   sess       The session object.
 * \param   sln_funcs  A list of per-solution object callbacks.
 * \param   prj_funcs  A list of per-project object callbacks.
 * \param   cfg_funcs  A list of per-configuration callbacks.
 * \returns OKAY if successful.
 */
int session_enumerate_objects(Session sess, SessionSolutionCallback* sln_funcs, SessionProjectCallback* prj_funcs, SessionProjectCallback* cfg_funcs)
{
	int si, sn;
	int result = OKAY;

	assert(sess);
	assert(sln_funcs);
	assert(prj_funcs);
	assert(cfg_funcs);

	/* enumerate solutions */
	sn = session_num_solutions(sess);
	for (si = 0; si < sn; ++si)
	{
		/* call all solution functions */
		int fi, pi, pn;
		Solution sln = session_get_solution(sess, si);
		for (fi = 0; result == OKAY && sln_funcs[fi] != NULL; ++fi)
		{
			result = sln_funcs[fi](sess, sln, sess->active_stream);
		}

		/* enumerate projects */
		pn = solution_num_projects(sln);
		for (pi = 0; pi < pn; ++pi)
		{
			Project prj = solution_get_project(sln, pi);
			for (fi = 0; result == OKAY && prj_funcs[fi]; ++fi)
			{
				/* A bit of black magic here - I use the "session_enumerate_configurations" 
				 * token to indicate where the list of configurations should appear in the
				 * project file. */
				if (prj_funcs[fi] == session_enumerate_configurations)
				{
					int ci, cn;
					cn = solution_num_configs(sln);
					for (ci = 0; result == OKAY && ci < cn; ++ci)
					{
						int cfi;
						const char* cfg_name = solution_get_config_name(sln, ci);
						project_set_configuration_filter(prj, cfg_name);

						/* enumerate configurations */
						for (cfi = 0; result == OKAY && cfg_funcs[cfi]; ++cfi)
						{
							result = cfg_funcs[cfi](sess, prj, sess->active_stream);
						}
					}
				}
				else
				{
					result = prj_funcs[fi](sess, prj, sess->active_stream);
				}
			}
		}
	}

	if (sess->active_stream)
	{
		stream_destroy(sess->active_stream);
		sess->active_stream = NULL;
	}

	return result;
}


/**
 * Get the action name to be performed by this execution run.
 * \param   sess    The session object.
 * \returns The action name if set, or NULL.
 */
const char* session_get_action(Session sess)
{
	assert(sess);
	return script_get_action(sess->script);
}


/**
 * Retrieve the currently active output stream.
 * \param   sess    The session object.
 * \return The currently active stream, or NULL if no stream is active.
 */
Stream session_get_active_stream(Session sess)
{
	assert(sess);
	return sess->active_stream;
}


/**
 * Retrieve the contained solution at the given index in the solution list.
 * \param   sess    The session object.
 * \param   index   The index of the solution to return.
 * \returns The solution object at the given index.
 */
Solution session_get_solution(Session sess, int index)
{
	assert(sess);
	assert(index >= 0 && array_size(sess->solutions) > 0 && index < array_size(sess->solutions));
	return (Solution)array_item(sess->solutions, index);
}

 
/**
 * Return the number of solutions contained by the session.
 * \param sess   The session object.
 */
int session_num_solutions(Session sess)
{
	assert(sess);
	return array_size(sess->solutions);
}


/**
 * Execute a script stored in a file.
 * \param   sess      The session object.
 * \param   filename  The name of the file containing the script code to be executed.
 * \returns If the script returns a value, it is converted to a string and returned.
 *          If the script does not return a value, NULL is returned. If an error
 *          occurs in the script, the error message is returned.
 */
const char* session_run_file(Session sess, const char* filename)
{
	assert(sess);
	return script_run_file(sess->script, filename);
}


/**
 * Execute a bit of script stored in a string.
 * \param   sess    The session object.
 * \param   code    The string containing the script code to be executed.
 * \returns If the script returns a value, it is converted to a string and returned.
 *          If the script does not return a value, NULL is returned. If an error
 *          occurs in the script, the error message is returned.
 */
const char* session_run_string(Session sess, const char* code)
{
	assert(sess);
	return script_run_string(sess->script, code);
}


/**
 * Set the action name to be performed on this execution pass. The action name will
 * be placed in the _ACTION script environment global.
 * \param   sess   The current execution session context.
 * \param   action The name of the action to be performed.
 */
void session_set_action(Session sess, const char* action)
{
	assert(sess);
	script_set_action(sess->script, action);
}


/**
 * Set the active output stream, which will be passed to subsequent callbacks during
 * object processing by session_enumerate_objects(). If there is an existing active
 * stream it will be released before setting the new stream.
 * \param   sess   The current execution session context.
 * \param   strm   The new active stream.
 */
void session_set_active_stream(Session sess, Stream strm)
{
	assert(sess);
	assert(strm);
	if (sess->active_stream) 
	{
		stream_destroy(sess->active_stream);
	}
	sess->active_stream = strm;
}


/**
 * Copy project information out of the scripting environment and into C objects that
 * can be more easily manipulated by the action code.
 * \param   sess   The session object which contains the scripted project objects.
 * \returns OKAY if successful.
 */
int session_unload(Session sess)
{
	assert(sess);
	return script_unload(sess->script, sess->solutions);
}


/**
 * Make sure that all required objects and values have been defined by the project script.
 * \param   sess      The session to validate.
 * \param   features  The features (language, kind, etc.) supported by the current action.
 * \returns OKAY if the session is valid.
 */
int session_validate(Session sess, SessionFeatures* features)
{
	int si, sn;
	
	assert(sess);
	assert(features);

	sn = session_num_solutions(sess);
	for (si = 0; si < sn; ++si)
	{
		int pi, pn;
		Solution sln = session_get_solution(sess, si);

		/* every solution must have at least one project */
		pn = solution_num_projects(sln);
		if (pn == 0)
		{
			error_set("no projects defined for solution '%s'", solution_get_name(sln));
			return !OKAY;
		}

		for (pi = 0; pi < pn; ++pi)
		{
			int i;

			Project prj = solution_get_project(sln, pi);
			const char* prj_name = project_get_name(prj);
			const char* prj_lang = project_get_language(prj);

			/* every project must have a language defined */
			if (prj_lang == NULL)
			{
				error_set("no language defined for project '%s'", prj_name);
				return !OKAY;
			}

			/* action must support the language */
			for (i = 0; features->languages[i] != NULL; ++i)
			{
				if (cstr_eq(prj_lang, features->languages[i]))
					break;
			}

			if (features->languages[i] == NULL)
			{
				error_set("%s language projects are not supported by this action", prj_lang);
				return !OKAY;
			}
		}
	}

	return OKAY;
}
