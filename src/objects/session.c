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
#include "objects_internal.h"
#include "base/array.h"
#include "base/cstr.h"
#include "base/env.h"
#include "base/error.h"


DEFINE_CLASS(Session)
{
	Array      solutions;
	Stream     active_stream;
};


/**
 * Create a new session object.
 * \returns A new session object, or NULL if the scripting engine fails to start.
 */
Session session_create(void)
{
	Session sess = ALLOC_CLASS(Session);
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
	solution_set_session(sln, sess);
}


/**
 * A bit of black magic: this function acts as a special token for the project handler
 * function list to indicate where configurations should appear. For more details, see
 * the implementation of session_enumerate_objects().
 */
int session_enumerate_configurations(Project prj, Stream strm)
{
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
			result = sln_funcs[fi](sln, sess->active_stream);
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
						const char* cfg_name = solution_get_config(sln, ci);
						project_set_config(prj, cfg_name);

						/* enumerate configurations */
						for (cfi = 0; result == OKAY && cfg_funcs[cfi]; ++cfi)
						{
							result = cfg_funcs[cfi](prj, sess->active_stream);
						}

						project_set_config(prj, NULL);
					}
				}
				else
				{
					result = prj_funcs[fi](prj, sess->active_stream);
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
			const char* prj_kind = project_get_kind(prj);
			const char* prj_lang = project_get_language(prj);

			/* every project must have these fields defined */
			if (prj_kind == NULL)
			{
				error_set("project '%s' needs a kind", prj_name);
				return !OKAY;
			}

			if (prj_lang == NULL)
			{
				error_set("project '%s' needs a language", prj_name);
				return !OKAY;
			}

			/* check actual project values against the list of supported values */
			for (i = 0; features->kinds[i] != NULL; ++i)
			{
				if (cstr_eqi(prj_kind, features->kinds[i]))
					break;
			}

			if (features->kinds[i] == NULL)
			{
				error_set("%s projects are not supported by this action", prj_kind);
				return !OKAY;
			}

			for (i = 0; features->languages[i] != NULL; ++i)
			{
				if (cstr_eqi(prj_lang, features->languages[i]))
					break;
			}

			if (features->languages[i] == NULL)
			{
				error_set("%s projects are not supported by this action", prj_lang);
				return !OKAY;
			}
		}
	}

	return OKAY;
}
