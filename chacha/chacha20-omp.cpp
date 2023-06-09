#include "chacha20.h"

#include <stdio.h>
#include <iostream>
#include <chrono>
#include <omp.h>

using namespace std;
using namespace std::chrono;


static uint32_t rotl32(uint32_t x, int n) 
{
	return (x << n) | (x >> (32 - n));
}

static uint32_t pack4(const uint8_t *a)
{
	uint32_t res = 0;
	for (int i = 0; i < 4; ++i) {
		res |= (uint32_t)a[i] << i * 8;
	}
	return res;
}
static void unpack4(uint32_t src, uint8_t *dst) {

	for (int i = 0; i < 4; ++i) {
		dst[i] = (src >> i * 8) & 0xff;
	}
	
}

static void chacha20_init_block(struct chacha20_context *ctx, uint8_t key[], uint8_t nonce[])
{
	memcpy(ctx->key, key, sizeof(ctx->key));
	memcpy(ctx->nonce, nonce, sizeof(ctx->nonce));

	const uint8_t *magic_constant = (uint8_t*)"expand 32-byte k";

	for (int i = 0; i < 4; ++i) {
		ctx->state[i] = pack4(magic_constant + i * 4);
	}

	for (int i = 0; i < 8; ++i) {
		ctx->state[4 + i] = pack4(key + i * 4);
	}
	
	ctx->state[12] = 0;

	for (int i = 0; i < 3; ++i) {
		ctx->state[13 + i] = pack4(nonce + i * 4);
	}

	memcpy(ctx->nonce, nonce, sizeof(ctx->nonce));
}

static void chacha20_block_set_counter(struct chacha20_context *ctx, uint64_t counter)
{
	ctx->state[12] = (uint32_t)counter;
	ctx->state[13] = pack4(ctx->nonce + 0 * 4) + (uint32_t)(counter >> 32);
}

static void quarterround(uint32_t x[], int a, int b, int c, int d) {
	x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 16); 
    x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 12);
    x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 8); 
    x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 7);
}

static void chacha20_block_next(struct chacha20_context *ctx) {
	for (int i = 0; i < 16; i++) ctx->keystream32[i] = ctx->state[i];

	for (int i = 0; i < 10; i++) 
	{
		quarterround(ctx->keystream32, 0, 4, 8, 12);
		quarterround(ctx->keystream32, 1, 5, 9, 13);
		quarterround(ctx->keystream32, 2, 6, 10, 14);
		quarterround(ctx->keystream32, 3, 7, 11, 15);
		quarterround(ctx->keystream32, 0, 5, 10, 15);
		quarterround(ctx->keystream32, 1, 6, 11, 12);
		quarterround(ctx->keystream32, 2, 7, 8, 13);
		quarterround(ctx->keystream32, 3, 4, 9, 14);
	}

	for (int i = 0; i < 16; i++) ctx->keystream32[i] += ctx->state[i];

	uint32_t *counter = ctx->state + 12;
	counter[0]++;
	if (0 == counter[0]) 
	{
		counter[1]++;
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
	int num_msgs = 64;

	uint8_t key[32] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
                    0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
                    0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0x00,
                    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};

	uint8_t nonce[12] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
                      0x11, 0x22, 0x33, 0x44};

	uint64_t counter = 123456789012345;

	uint8_t data[num_msgs][5];
	for(int i = 0; i < num_msgs; i++) {
		data[i][0] = 0x01;
		data[i][1] = 0x01;
		data[i][2] = 0x01;
		data[i][3] = 0x01;
		data[i][4] = 0x01;
	}
	
	int target_len = 1024;
	uint8_t output[num_msgs][target_len];

	auto start = high_resolution_clock::now();
	omp_set_num_threads(16);
	#pragma omp parallel for schedule(static)
	for (int i=0; i<num_msgs; i++) {
		struct chacha20_context ctx;
		chacha20_init_context(&ctx, key, nonce, counter);

		int data_len = sizeof(data[i]) / sizeof(data[i][0]);

		int num_repeats = target_len / data_len;
		for (int j = 0; j < num_repeats; j++) {
			memcpy(&output[i][j * data_len], data[i], data_len);
		}

		int remaining_len = target_len % data_len;
		if (remaining_len > 0) {
			memcpy(&output[i][num_repeats * data_len], data[i], remaining_len);
		}

		uint8_t *buffer = output[i];
		size_t size_of_buffer = 1024;
		chacha20_xor(&ctx, buffer, size_of_buffer);
	}

	auto stop = high_resolution_clock::now();

	auto duration = duration_cast<microseconds>(stop - start);

	cout << "Time taken by function: " << duration.count() << " microseconds" << endl;

	// display_bytes(data, 512);
    return 0;
}