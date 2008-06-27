/**
 * \file   block.c
 * \brief  The configuration block class.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/block.h"


struct FieldInfo BlockFieldInfo[] =
{
	{ "defines",    ListField,    NULL  },
	{ "objdir",     StringField,  NULL  },
	{  0,           0,            NULL  }
};


DEFINE_CLASS(Block)
{
	Fields fields;
};


/**
 * Create and initialize a new configuration block.
 * \returns A new configuration block.
 */
Block block_create()
{
	Block blk = ALLOC_CLASS(Block);
	blk->fields = fields_create(BlockFieldInfo);
	return blk;
}


/**
 * Destroy a configuration block and release the associated memory.
 * \param   blk   The configuration block to destroy.
 */
void block_destroy(Block blk)
{
	assert(blk);
	fields_destroy(blk->fields);
	free(blk);
}


/**
 * Retrieve the list of defines associated with a block.
 */
Strings block_get_defines(Block blk)
{
	assert(blk);
	return fields_get_values(blk->fields, BlockDefines);
}


/**
 * Retrieve the fields object for this block; used to unload values from the script.
 */
Fields block_get_fields(Block blk)
{
	assert(blk);
	return blk->fields;
}
