#include "chacha20.h"

#include <stdio.h>
#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;


static uint32_t rotl32(uint32_t x, int n) 
{
	return (x << n) | (x >> (32 - n));
}

static uint32_t pack4(const uint8_t *a)
{
	uint32_t res = 0;
	res |= (uint32_t)a[0] << 0 * 8;
	res |= (uint32_t)a[1] << 1 * 8;
	res |= (uint32_t)a[2] << 2 * 8;
	res |= (uint32_t)a[3] << 3 * 8;
	return res;
}

static void unpack4(uint32_t src, uint8_t *dst) {
	dst[0] = (src >> 0 * 8) & 0xff;
	dst[1] = (src >> 1 * 8) & 0xff;
	dst[2] = (src >> 2 * 8) & 0xff;
	dst[3] = (src >> 3 * 8) & 0xff;
}

static void chacha20_init_block(struct chacha20_context *ctx, uint8_t key[], uint8_t nonce[])
{
	memcpy(ctx->key, key, sizeof(ctx->key));
	memcpy(ctx->nonce, nonce, sizeof(ctx->nonce));

	const uint8_t *magic_constant = (uint8_t*)"expand 32-byte k";
	ctx->state[0] = pack4(magic_constant + 0 * 4);
	ctx->state[1] = pack4(magic_constant + 1 * 4);
	ctx->state[2] = pack4(magic_constant + 2 * 4);
	ctx->state[3] = pack4(magic_constant + 3 * 4);
	ctx->state[4] = pack4(key + 0 * 4);
	ctx->state[5] = pack4(key + 1 * 4);
	ctx->state[6] = pack4(key + 2 * 4);
	ctx->state[7] = pack4(key + 3 * 4);
	ctx->state[8] = pack4(key + 4 * 4);
	ctx->state[9] = pack4(key + 5 * 4);
	ctx->state[10] = pack4(key + 6 * 4);
	ctx->state[11] = pack4(key + 7 * 4);
	// 64 bit counter initialized to zero by default.
	ctx->state[12] = 0;
	ctx->state[13] = pack4(nonce + 0 * 4);
	ctx->state[14] = pack4(nonce + 1 * 4);
	ctx->state[15] = pack4(nonce + 2 * 4);

	memcpy(ctx->nonce, nonce, sizeof(ctx->nonce));
}

static void chacha20_block_set_counter(struct chacha20_context *ctx, uint64_t counter)
{
	ctx->state[12] = (uint32_t)counter;
	ctx->state[13] = pack4(ctx->nonce + 0 * 4) + (uint32_t)(counter >> 32);
}

static void chacha20_block_next(struct chacha20_context *ctx) {
	// This is where the crazy voodoo magic happens.
	// Mix the bytes a lot and hope that nobody finds out how to undo it.
	for (int i = 0; i < 16; i++) ctx->keystream32[i] = ctx->state[i];

#define CHACHA20_QUARTERROUND(x, a, b, c, d) \
    x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 16); \
    x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 12); \
    x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 8); \
    x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 7);

	for (int i = 0; i < 10; i++) 
	{
		CHACHA20_QUARTERROUND(ctx->keystream32, 0, 4, 8, 12)
		CHACHA20_QUARTERROUND(ctx->keystream32, 1, 5, 9, 13)
		CHACHA20_QUARTERROUND(ctx->keystream32, 2, 6, 10, 14)
		CHACHA20_QUARTERROUND(ctx->keystream32, 3, 7, 11, 15)
		CHACHA20_QUARTERROUND(ctx->keystream32, 0, 5, 10, 15)
		CHACHA20_QUARTERROUND(ctx->keystream32, 1, 6, 11, 12)
		CHACHA20_QUARTERROUND(ctx->keystream32, 2, 7, 8, 13)
		CHACHA20_QUARTERROUND(ctx->keystream32, 3, 4, 9, 14)
	}

	for (int i = 0; i < 16; i++) ctx->keystream32[i] += ctx->state[i];

	uint32_t *counter = ctx->state + 12;
	// increment counter
	counter[0]++;
	if (0 == counter[0]) 
	{
		// wrap around occured, increment higher 32 bits of counter
		counter[1]++;
		// Limited to 2^64 blocks of 64 bytes each.
		// If you want to process more than 1180591620717411303424 bytes
		// you have other problems.
		// We could keep counting with counter[2] and counter[3] (nonce),
		// but then we risk reusing the nonce which is very bad.
		assert(0 != counter[1]);
	}
}

void chacha20_init_context(struct chacha20_context *ctx, uint8_t key[], uint8_t nonce[], uint64_t counter)
{
	memset(ctx, 0, sizeof(struct chacha20_context));

	chacha20_init_block(ctx, key, nonce);
	chacha20_block_set_counter(ctx, counter);

	ctx->counter = counter;
	ctx->position = 64;
}

void chacha20_xor(struct chacha20_context *ctx, uint8_t *bytes, size_t n_bytes)
{
	uint8_t *keystream8 = (uint8_t*)ctx->keystream32;
	for (size_t i = 0; i < n_bytes; i++) 
	{
		if (ctx->position >= 64) 
		{
			chacha20_block_next(ctx);
			ctx->position = 0;
		}
		bytes[i] ^= keystream8[ctx->position];
		ctx->position++;
	}
}

void display_bytes(uint8_t *bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        printf("%02x ", bytes[i]);
    }
    printf("\n");
}


int main() {

	struct chacha20_context ctx;

	uint8_t key[32] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
                    0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
                    0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0x00,
                    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};

	uint8_t nonce[12] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
                      0x11, 0x22, 0x33, 0x44};

	uint64_t counter = 123456789012345;

	chacha20_init_context(&ctx, key, nonce, counter);

	uint8_t data[] = {0x01, 0x02, 0x03, 0x04, 0x05};
	const int data_len = sizeof(data) / sizeof(data[0]);
    const int target_len = 512;
    uint8_t output[target_len];
    
    int num_repeats = target_len / data_len;
    for (int i = 0; i < num_repeats; i++) {
        std::memcpy(&output[i * data_len], data, data_len);
    }

    int remaining_len = target_len % data_len;
    if (remaining_len > 0) {
        std::memcpy(&output[num_repeats * data_len], data, remaining_len);
    }

	uint8_t *buffer = output;
	size_t size_of_buffer = 512;

	auto start = high_resolution_clock::now();

    for (int i = 0; i < 10000; ++i) {
        chacha20_xor(&ctx, buffer, size_of_buffer);
    }

	auto stop = high_resolution_clock::now();

	auto duration = duration_cast<nanoseconds>(stop - start)/10000;

	cout << "Time taken by function: "
         << duration.count() << " nanoseconds" << endl;

	// display_bytes(data, 512);
    return 0;
}