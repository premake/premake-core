/**
 * \file   sourcetree.h
 * \brief  Source code tree enumerator.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_SOURCETREE_H)
#define PREMAKE_SOURCETREE_H

#include "objects/project.h"


/**
 * State values for the source tree enumeration functions.
 */
enum SourceTreeState
{
	GroupStart,
	GroupEnd,
	SourceFile
};


/**
 * Per-file callback signature for action_source_tree.
 * \param   prj       The current project; contains the file being enumerated.
 * \param   strm      The active output stream; for writing the file markup.
 * \param   filename  The name of the file to process.
 * \param   state     One of the ActionSourceStates, enabling file grouping.
 * \returns OKAY if successful.
 */
typedef int (*SourceTreeCallback)(Project prj, Stream strm, const char* filename, int state);


int  sourcetree_walk(Project prj, Stream strm, SourceTreeCallback handler);


#endif
