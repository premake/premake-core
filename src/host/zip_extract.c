/**
* \file   os_unzip.c
* \brief  Unzip file using libzip library.
* \author battle.net -- abrunasso.int@blizzard.com
*/

#include "premake.h"

#ifdef PREMAKE_COMPRESSION

#include <zip.h>

#ifdef WIN32
#include <direct.h>
#include <io.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>

// File Attribute for Unix
#define FA_IFIFO  0010000  /* named pipe (fifo) */
#define FA_IFCHR  0020000  /* character special */
#define FA_IFDIR  0040000  /* directory */
#define FA_IFBLK  0060000  /* block special */
#define FA_IFREG  0100000  /* regular */
#define FA_IFLNK  0120000  /* symbolic link */
#define FA_IFSOCK 0140000  /* socket */

#define FA_ISUID 0004000 /* set user id on execution */
#define FA_ISGID 0002000 /* set group id on execution */
#define FA_ISTXT 0001000 /* sticky bit */
#define FA_IRWXU 0000700 /* RWX mask for owner */
#define FA_IRUSR 0000400 /* R for owner */
#define FA_IWUSR 0000200 /* W for owner */
#define FA_IXUSR 0000100 /* X for owner */
#define FA_IRWXG 0000070 /* RWX mask for group */
#define FA_IRGRP 0000040 /* R for group */
#define FA_IWGRP 0000020 /* W for group */
#define FA_IXGRP 0000010 /* X for group */
#define FA_IRWXO 0000007 /* RWX mask for other */
#define FA_IROTH 0000004 /* R for other */
#define FA_IWOTH 0000002 /* W for other */
#define FA_IXOTH 0000001 /* X for other */
#define FA_ISVTX 0001000 /* save swapped text even after use */

// ----------------------------------------------------------------------------

static int is_symlink(zip_uint8_t opsys, zip_uint32_t attrib)
{
	if (opsys == ZIP_OPSYS_DOS)
		return (attrib & 0x400) == 0x400;  // FILE_ATTRIBUTE_REPARSE_POINT

	if (opsys == ZIP_OPSYS_UNIX)
		return ((attrib >> 16) & FA_IFLNK) == FA_IFLNK;

	return 0;
}


static int is_directory(zip_uint8_t opsys, zip_uint32_t attrib)
{
	if (opsys == ZIP_OPSYS_DOS)
		return (attrib & 0x10) == 0x10;  // FILE_ATTRIBUTE_DIRECTORY

	if (opsys == ZIP_OPSYS_UNIX)
		return ((attrib >> 16) & FA_IFDIR) == FA_IFDIR;

	return 0;
}


static int write_link(const char* filename, const char* bytes, size_t count)
{
#if PLATFORM_POSIX
	(void)(count);
	return symlink(bytes, filename);
#else
	FILE* fp = fopen(filename, "wb");
	if (fp == NULL)
	{
		printf("Error creating file:\n  %s\n", filename);
		return -1;
	}
	fwrite(bytes, sizeof(char), count, fp);
	fclose(fp);
	return 0;
#endif
}

extern int do_mkdir(const char* path);

static void parse_path(const char* full_name, char* filename, char* directory)
{
	const char *ssc;
	size_t orig_length = strlen(full_name);
	size_t l = 0;
	size_t dir_size;

	ssc = strstr(full_name, "/");
	do
	{
		l = strlen(ssc) + 1;
		full_name = &full_name[strlen(full_name) - l + 2];
		ssc = strstr(full_name, "/");
	} while (ssc);

	// full_name currently pointing to beginning of filename
	memcpy(filename, full_name, strlen(full_name));
	filename[strlen(full_name)] = 0; // Null terminate it

	dir_size = orig_length - strlen(filename);
	// full_name points to beginning of original string(with directory)
	full_name = &full_name[strlen(full_name) - orig_length];

	// Extract directory from full name by removing filename
	memcpy(directory, full_name, dir_size);
	directory[dir_size] = 0;
}


static int extract(const char* src, const char* destination)
{
	int err = 0;
	FILE *fp = NULL;
	struct zip *z_archive = zip_open(src, 0, &err);
	int i;
	zip_int64_t entries;
	char buffer[4096];
	char appended_full_name[512];
	char directory[512];
	char filename[512];
	size_t result;
	zip_int64_t bytes_read;

	if (!z_archive)
	{
		printf("%s does not exist\n", src);
		return -1;
	}

	for (i = 0, entries = zip_get_num_entries(z_archive, 0); i < entries; ++i)
	{
		zip_uint8_t opsys;
		zip_uint32_t attrib;
		const char* full_name;

		struct zip_file* zf = zip_fopen_index(z_archive, i, 0);
		if (!zf)
			continue;

		zip_file_get_external_attributes(z_archive, i, 0, &opsys, &attrib);

		full_name = zip_get_name(z_archive, i, 0);

		sprintf(appended_full_name, "%s/%s", destination, full_name);
		do_translate(appended_full_name, '/');

		parse_path(appended_full_name, filename, directory);
		do_mkdir(directory);

		// is this a symbolic link?
		if (is_symlink(opsys, attrib))
		{
			bytes_read = zip_fread(zf, buffer, sizeof(buffer));
			buffer[bytes_read] = '\0';
			if (write_link(appended_full_name, buffer, (size_t)bytes_read) != 0)
			{
				printf("  Failed to create symbolic link [%s->%s]\n", appended_full_name, buffer);
				return -1;
			}
		} else
		{
			// If blank filename it's just a directory so create it and move on
			if (!is_directory(opsys, attrib) && strlen(filename) > 0)
			{
				// mark as read-write, so we can overwrite the file if it already exists.
				chmod(appended_full_name, 0666);

				fp = fopen(appended_full_name, "wb");
				if (fp == NULL)
				{
					printf("Error creating file:\n  %s\n", appended_full_name);
					return -1;
				}
				for(;;)
				{
					// Read content from zipped file
					bytes_read = zip_fread(zf, buffer, sizeof(buffer));
					if (bytes_read == 0) break;
					// Write that content to file
					result = fwrite(buffer, sizeof(char), (size_t)bytes_read, fp);
					// If all bytes read weren't written, report error
					if (result != (size_t)bytes_read)
					{
						printf("  Writing data to %s failed\n   %d bytes were written\n    %d bytes were attempted to be written\n    File may be corrupt\n",
							appended_full_name, (int)result, (int)bytes_read);
						return -1;
					}
				}

				fclose(fp);

				// mark read-only, but maintain the other properties.
				if (opsys == ZIP_OPSYS_UNIX)
					chmod(appended_full_name, (attrib >> 16) & ~0222);
				else
					chmod(appended_full_name, 0444);
			}
		}

		// Cleanup
		zip_fclose(zf);
	}
	zip_close(z_archive);

	return 0;
}


int zip_extract(lua_State* L)
{
	const char* src = luaL_checkstring(L, 1);
	const char* dst = luaL_checkstring(L, 2);

	int res = extract(src, dst);

	lua_pushnumber(L, (lua_Number)res);
	return 1;
}

#endif
