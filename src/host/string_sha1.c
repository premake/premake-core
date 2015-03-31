#include <stdint.h>
#include <string.h>
#include "premake.h"

#define HASH_LENGTH 20
#define BLOCK_LENGTH 64

typedef struct sha1nfo {
	uint32_t buffer[BLOCK_LENGTH / 4];
	uint32_t state[HASH_LENGTH / 4];
	uint32_t byteCount;
	uint8_t bufferOffset;
	uint8_t keyBuffer[BLOCK_LENGTH];
	uint8_t innerHash[HASH_LENGTH];
} sha1nfo;

/* public API - prototypes - TODO: doxygen*/
void sha1_init(sha1nfo *s);
void sha1_writebyte(sha1nfo *s, uint8_t data);
void sha1_write(sha1nfo *s, const char *data, size_t len);
uint8_t* sha1_result(sha1nfo *s);

/* code */
#define SHA1_K0  0x5a827999
#define SHA1_K20 0x6ed9eba1
#define SHA1_K40 0x8f1bbcdc
#define SHA1_K60 0xca62c1d6

void sha1_init(sha1nfo *s)
{
	s->state[0] = 0x67452301;
	s->state[1] = 0xefcdab89;
	s->state[2] = 0x98badcfe;
	s->state[3] = 0x10325476;
	s->state[4] = 0xc3d2e1f0;
	s->byteCount = 0;
	s->bufferOffset = 0;
}

uint32_t sha1_rol32(uint32_t number, uint8_t bits)
{
	return ((number << bits) | (number >> (32 - bits)));
}

void sha1_hashBlock(sha1nfo *s)
{
	uint8_t i;
	uint32_t a, b, c, d, e, t;

	a = s->state[0];
	b = s->state[1];
	c = s->state[2];
	d = s->state[3];
	e = s->state[4];
	for (i = 0; i < 80; i++)
	{
		if (i >= 16)
		{
			t = s->buffer[(i + 13) & 15] ^ s->buffer[(i + 8) & 15] ^ s->buffer[(i + 2) & 15] ^ s->buffer[i & 15];
			s->buffer[i & 15] = sha1_rol32(t, 1);
		}
		if (i < 20)
		{
			t = (d ^ (b & (c ^ d))) + SHA1_K0;
		}
		else if (i < 40)
		{
			t = (b ^ c ^ d) + SHA1_K20;
		}
		else if (i < 60)
		{
			t = ((b & c) | (d & (b | c))) + SHA1_K40;
		}
		else
		{
			t = (b ^ c ^ d) + SHA1_K60;
		}
		t += sha1_rol32(a, 5) + e + s->buffer[i & 15];
		e = d;
		d = c;
		c = sha1_rol32(b, 30);
		b = a;
		a = t;
	}
	s->state[0] += a;
	s->state[1] += b;
	s->state[2] += c;
	s->state[3] += d;
	s->state[4] += e;
}

void sha1_addUncounted(sha1nfo *s, uint8_t data)
{
	uint8_t * const b = (uint8_t*)s->buffer;
	b[s->bufferOffset ^ 3] = data;
	s->bufferOffset++;
	if (s->bufferOffset == BLOCK_LENGTH)
	{
		sha1_hashBlock(s);
		s->bufferOffset = 0;
	}
}

void sha1_writebyte(sha1nfo *s, uint8_t data)
{
	++s->byteCount;
	sha1_addUncounted(s, data);
}

void sha1_write(sha1nfo *s, const char *data, size_t len)
{
	for (; len--;) sha1_writebyte(s, (uint8_t)*data++);
}

void sha1_pad(sha1nfo *s) 
{
	// Implement SHA-1 padding (fips180-2 §5.1.1)

	// Pad with 0x80 followed by 0x00 until the end of the block
	sha1_addUncounted(s, 0x80);
	while (s->bufferOffset != 56) sha1_addUncounted(s, 0x00);

	// Append length in the last 8 bytes
	sha1_addUncounted(s, 0); // We're only using 32 bit lengths
	sha1_addUncounted(s, 0); // But SHA-1 supports 64 bit lengths
	sha1_addUncounted(s, 0); // So zero pad the top bits
	sha1_addUncounted(s, s->byteCount >> 29); // Shifting to multiply by 8
	sha1_addUncounted(s, (uint8_t)(s->byteCount >> 21)); // as SHA-1 supports bitstreams as well as
	sha1_addUncounted(s, (uint8_t)(s->byteCount >> 13)); // byte.
	sha1_addUncounted(s, (uint8_t)(s->byteCount >> 5));
	sha1_addUncounted(s, (uint8_t)(s->byteCount << 3));
}

uint8_t* sha1_result(sha1nfo *s) 
{
	int i;

	// Pad to complete the last block
	sha1_pad(s);

	// Swap byte order back
	for (i = 0; i < 5; i++) 
	{
		s->state[i] =
			(((s->state[i]) << 24) & 0xff000000)
			| (((s->state[i]) << 8) & 0x00ff0000)
			| (((s->state[i]) >> 8) & 0x0000ff00)
			| (((s->state[i]) >> 24) & 0x000000ff);
	}

	// Return pointer to hash (20 characters)
	return (uint8_t*)s->state;
}



int string_sha1(lua_State* L)
{
	static const char* g_int2hex = "0123456789ABCDEF";
	uint8_t* result;
	size_t l;
	sha1nfo s;
	int i;
	char output[41];

	const char *str = luaL_checklstring(L, 1, &l);
	if (str != NULL)
	{
		sha1_init(&s);
		sha1_write(&s, str, l);
		result = sha1_result(&s);

		for (i = 0; i < 20; ++i)
		{
			output[i * 2 + 0] = g_int2hex[result[i] & 0x0f];
			output[i * 2 + 1] = g_int2hex[result[i] >> 4];
		}
		output[40] = 0;

		lua_pushlstring(L, output, 40);
		return 1;
	}

	return 0;
}
