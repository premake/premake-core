/**
 * \file   blocks.h
 * \brief  A list of configuration blocks.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "project/blocks.h"
#include "base/array.h"


DEFINE_CLASS(Blocks)
{
	Array blocks;
};


/**
 * Create and initialize a new list of configuration blocks.
 * \returns A new configuration block list.
 */
Blocks blocks_create(void)
{
	Blocks blks = ALLOC_CLASS(Blocks);
	blks->blocks = array_create();
	return blks;
}


/**
 * Destroy a configuration block list and release the associated memory.
 * \param   blks   The configuration block list to destroy.
 */
void blocks_destroy(Blocks blks)
{
	int i, n;
	assert(blks);
	n = blocks_size(blks);
	for (i = 0; i < n; ++i)
	{
		Block blk = blocks_item(blks, i);
		block_destroy(blk);
	}
	array_destroy(blks->blocks);
	free(blks);
}


/**
 * Add a new block to a list.
 * \param   blks      The configuration block list.
 * \param   blk       The block to add to the list.
 */
void blocks_add(Blocks blks, Block blk)
{
	assert(blks);
	assert(blk);
	array_add(blks->blocks, blk);
}


/**
 * Retrieve an item from the list of blocks.
 * \param   blks      The configuration block list.
 * \param   index     The index of the item to retrieve.
 * \returns The block at the given index.
 */
Block blocks_item(Blocks blks, int index)
{
	assert(blks);
	return (Block)array_item(blks->blocks, index);
}


/**
 * Returns the number of blocks in the list.
 * \param   blks      The configuration block list.
 */
int blocks_size(Blocks blks)
{
	return array_size(blks->blocks);
}
