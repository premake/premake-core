/**
 * \file   block.c
 * \brief  The configuration block class.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "block.h"
#include "base/cstr.h"
#include "base/env.h"


struct FieldInfo BlockFieldInfo[] =
{
	{ "defines",    ListField,    NULL  },
	{ "objdir",     StringField,  NULL  },
	{ "terms",      ListField,    NULL  },
	{  0,           0,            NULL  }
};


DEFINE_CLASS(Block)
{
	Fields fields;
};


/**
 * Create and initialize a new configuration block.
 */
Block block_create()
{
	Block blk = ALLOC_CLASS(Block);
	blk->fields = fields_create(BlockFieldInfo);
	return blk;
}


/**
 * Destroy a configuration block and release the associated memory.
 */
void block_destroy(Block blk)
{
	assert(blk);
	fields_destroy(blk->fields);
	free(blk);
}


/**
 * Checks the block's list of terms to see if this block applies to
 * the current environment. All of the block's terms must find a match
 * among the keyword sources, which include the current OS, the action,
 * and the provided configuration name.
 * \param   blk       The block to test.
 * \param   cfg_name  The name of the active configuration.
 * \returns True if every term in the block finds a keyword match.
 */
int block_applies_to(Block blk, const char* cfg_name)
{
	int i, n;
	Strings terms = block_get_values(blk, BlockTerms);
	n = strings_size(terms);
	for (i = 0; i < n; ++i)
	{
		const char* term = strings_item(terms, i);
		if ((cfg_name != NULL && cstr_matches_pattern(cfg_name, term)) ||
			cstr_matches_pattern(env_get_os_name(), term) ||
			cstr_matches_pattern(env_get_action(), term))
		{
			continue;
		}

		/* no match was found for this term */
		return 0;
	}
	
	return 1;
}

 
/**
 * Retrieve the fields object for this block; used to unload values from the script.
 */
Fields block_get_fields(Block blk)
{
	assert(blk);
	return blk->fields;
}


/**
 * Retrieve a list of values associated with a block.
 */
Strings block_get_values(Block blk, enum BlockField which)
{
	assert(blk);
	return fields_get_values(blk->fields, which);
}


/**
 * Set a value list field on the block.
 */
void block_set_values(Block blk, enum BlockField which, Strings strs)
{
	assert(blk);
	fields_set_values(blk->fields, which, strs);
}
