/**
 * \file   sourcetree.h
 * \brief  Source code tree enumerator.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include "premake.h"
#include "sourcetree.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/string.h"


static int sourcetree_do(Project prj, Stream strm, SourceTreeCallback handler, const char* group);


/**
 * Walk a list of source files and pass them off, in nesting order, to
 * the specified callback. Handles the grouping of related files info
 * groups (by directory currently).
 * \param   prj      The project containing the files to enumerate.
 * \param   strm     The active output stream.
 * \param   handler  The per-file handler function.
 * \returns OKAY on success.
 */
int sourcetree_walk(Project prj, Stream strm, SourceTreeCallback handler)
{
	return sourcetree_do(prj, strm, handler, "");
}


static int sourcetree_do(Project prj, Stream strm, SourceTreeCallback handler, const char* group)
{
	int i, n;
	unsigned group_len;
	Strings files;
	char* buffer;

	group_len = strlen(group);

	/* open an enclosing group */
	buffer = buffers_next();
	strcpy(buffer, group);
	cstr_trim(buffer, '/');
	handler(prj, strm, buffer, GroupStart);

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
				buffer = buffers_next();
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
					String new_group = string_create(buffer);
					int z = sourcetree_do(prj, strm, handler, string_cstr(new_group));
					string_destroy(new_group);
					if (z != OKAY) return !OKAY;
				}
			}
		}
	}

	/* now process all files that belong to this current group (and not a subgroup) */
	for (i = 0; i < n; ++i)
	{
		const char* filename = strings_item(files, i);
		if (cstr_starts_with(filename, group) && strchr(filename + group_len, '/') == NULL)
		{
			if (handler(prj, strm, filename, SourceFile) != OKAY)
				return !OKAY;
		}
	}

	/* close the group */
	buffer = buffers_next();
	strcpy(buffer, group);
	cstr_trim(buffer, '/');
	handler(prj, strm, buffer, GroupEnd);
	return OKAY;
}

