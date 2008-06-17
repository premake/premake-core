/**
 * \file   action.c
 * \brief  Built-in engine actions.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include "premake.h"
#include "action/action.h"
#include "base/buffers.h"
#include "base/cstr.h"

SessionAction Actions[] = 
{
	{ "gmake",   "GNU Makefiles for POSIX, MinGW, and Cygwin",                gmake_action  },
	{ "vs2002",  "Microsoft Visual Studio 2002",                              vs2002_action },
	{ "vs2003",  "Microsoft Visual Studio 2003",                              vs2003_action },
	{ "vs2005",  "Microsoft Visual Studio 2005 (includes Express editions)",  vs2005_action },
	{ "vs2008",  "Microsoft Visual Studio 2008 (includes Express editions)",  vs2008_action },
	{ 0, 0, 0 }
};

static int action_source_tree_do(Session sess, Project prj, Stream strm, ActionSourceCallback handler, const char* group);


/**
 * Walk a list of source files and pass them off, in nesting order, to
 * the specified callback. Handles the grouping of related files info
 * groups (by directory currently).
 * \param   sess     The current execution session context.
 * \param   prj      The project containing the files to enumerate.
 * \param   strm     The active output stream.
 * \param   handler  The per-file handler function.
 * \returns OKAY on success.
 */
int action_source_tree(Session sess, Project prj, Stream strm, ActionSourceCallback handler)
{
	return action_source_tree_do(sess, prj, strm, handler, "");
}


static int action_source_tree_do(Session sess, Project prj, Stream strm, ActionSourceCallback handler, const char* group)
{
	int i, n, group_len;
	Strings files;
	char* buffer = buffers_next();

	/* open an enclosing group */
	group_len = strlen(group);
	strcpy(buffer, group);
	if (cstr_ends_with(buffer, "/"))  /* Trim off trailing path separator */
	{
		buffer[strlen(buffer)-1] = '\0';
	}
	handler(sess, prj, strm, buffer, GroupStart);

	/* scan all files in this group and process any subdirectories (subgroups) */
	files = project_get_files(prj);
	n = strings_size(files);
	for (i = 0; i < n; ++i)
	{
		const char* filename = strings_item(files, i);

		/* is this file in the group that I am currently processing? */
		if (cstr_starts_with(filename, group))
		{
			/* see if this file contains an additional directory level (a new group) */
			const char* ptr = strchr(filename + group_len, '/');
			if (ptr)
			{
				int j;

				/* pull out the name of this new group */
				size_t len = ptr - filename + 1;
				strncpy(buffer, filename, len);
				buffer[len] = '\0';

				/* have I processed this subdirectory already? See if it appears earlier in the list */
				for (j = 0; j < i; ++j)
				{
					if (cstr_starts_with(strings_item(files, j), buffer))
						break;
				}

				if (i == j)
				{
					/* a new group, process it now */
					if (action_source_tree_do(sess, prj, strm, handler, buffer) != OKAY)
						return !OKAY;
				}
			}
		}
	}

	/* now process all files that belong to this current group (and not a subgroup) */
	for (i = 0; i < n; ++i)
	{
		const char* filename = strings_item(files, i);
		if (!strchr(filename + group_len, '/'))
		{
			if (handler(sess, prj, strm, filename, SourceFile) != OKAY)
				return !OKAY;
		}
	}

	/* close the group */
	strcpy(buffer, group);
	if (cstr_ends_with(buffer, "/"))  /* Trim off trailing path separator */
	{
		buffer[strlen(buffer)-1] = '\0';
	}
	handler(sess, prj, strm, buffer, GroupEnd);
	return OKAY;
}

