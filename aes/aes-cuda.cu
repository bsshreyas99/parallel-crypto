#include <stdio.h>  // for printf
#include <stdlib.h> // for malloc
#include <cuda.h>
#include <chrono>
#include <iostream>

#define UNKNOWN_KEYSIZE 11
#define MEMORY_ALLOCATION_PROBLEM 33

// Implementation: S-Box

unsigned char sbox[256] = {
    // 0     1    2      3     4    5     6     7      8    9     A      B    C     D     E     F
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,  // 0
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,  // 1
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,  // 2
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,  // 3
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,  // 4
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,  // 5
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,  // 6
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,  // 7
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,  // 8
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,  // 9
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,  // A
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,  // B
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,  // C
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,  // D
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,  // E
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16}; // F

// Implementation: Rcon
unsigned char Rcon[255] = {

    0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,
    0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3,
    0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f,
    0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d,
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab,
    0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d,
    0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25,
    0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01,
    0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d,
    0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa,
    0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a,
    0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02,
    0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a,
    0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef,
    0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94,
    0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04,
    0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f,
    0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5,
    0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33,
    0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb};


enum keySize
{
    SIZE_16 = 16,
    SIZE_24 = 24,
    SIZE_32 = 32
};

/* Rijndael's key schedule rotate operation
 * rotate the word eight bits to the left
 *
 * rotate(1d2c3a4f) = 2c3a4f1d
 *
 * word is an char array of size 4 (32 bit)
 */
void rotate(unsigned char *word)
{
    unsigned char c;
    int i;

    c = word[0];
    for (i = 0; i < 3; i++)
        word[i] = word[i + 1];
    word[3] = c;
}

void core(unsigned char *word, int iteration)
{
    int i;

    /* rotate the 32-bit word 8 bits to the left */
    rotate(word);

    /* apply S-Box substitution on all 4 parts of the 32-bit word */
    for (i = 0; i < 4; ++i)
    {
        word[i] = sbox[word[i]];
    }

    /* XOR the output of the rcon operation with i to the first part (leftmost) only */
    word[0] = word[0] ^ Rcon[iteration];
}

/* Rijndael's key expansion
 * expands an 128,192,256 key into an 176,208,240 bytes key
 *
 * expandedKey is a pointer to an char array of large enough size
 * key is a pointer to a non-expanded key
 */

void expandKey(unsigned char *expandedKey,
               unsigned char *key,
               enum keySize size,
               size_t expandedKeySize)
{
    /* current expanded keySize, in bytes */
    int currentSize = 0;
    int rconIteration = 1;
    int i;
    unsigned char t[4] = {0}; // temporary 4-byte variable

    /* set the 16,24,32 bytes of the expanded key to the input key */
    for (i = 0; i < size; i++)
        expandedKey[i] = key[i];
    currentSize += size;

    while (currentSize < expandedKeySize)
    {
        /* assign the previous 4 bytes to the temporary value t */
        for (i = 0; i < 4; i++)
        {
            t[i] = expandedKey[(currentSize - 4) + i];
        }

        /* every 16,24,32 bytes we apply the core schedule to t
         * and increment rconIteration afterwards
         */
        if (currentSize % size == 0)
        {
            core(t, rconIteration++);
        }

        /* For 256-bit keys, we add an extra sbox to the calculation */
        if (size == SIZE_32 && ((currentSize % size) == 16))
        {
            for (i = 0; i < 4; i++)
                t[i] = sbox[t[i]];
        }

        /* We XOR t with the four-byte block 16,24,32 bytes before the new expanded key.
         * This becomes the next four bytes in the expanded key.
         */
        for (i = 0; i < 4; i++)
        {
            expandedKey[currentSize] = expandedKey[currentSize - size] ^ t[i];
            currentSize++;
        }
    }
}

__device__ void subBytes(unsigned char *state, unsigned char *sbox)
{
    int i;
    /* substitute all the values from the state with the value in the SBox
     * using the state value as index for the SBox
     */
    for (i = 0; i < 16; i++)
        state[i] = sbox[state[i]];
}

__device__ void shiftRow(unsigned char *state, unsigned char nbr)
{
    int i, j;
    unsigned char tmp;
    /* each iteration shifts the row to the left by 1 */
    for (i = 0; i < nbr; i++)
    {
        tmp = state[0];
        for (j = 0; j < 3; j++)
            state[j] = state[j + 1];
        state[3] = tmp;
    }
}

__device__ void shiftRows(unsigned char *state)
{
    int i;
    /* iterate over the 4 rows and call shiftRow() with that row */
    for (i = 0; i < 4; i++)
        shiftRow(state + i * 4, i);
}

__device__ void addRoundKey(unsigned char *state, unsigned char *roundKey)
{
    int i;
    for (i = 0; i < 16; i++)
        state[i] = state[i] ^ roundKey[i];
}

__device__ unsigned char galois_multiplication(unsigned char a, unsigned char b)
{
    unsigned char p = 0;
    unsigned char counter;
    unsigned char hi_bit_set;
    for (counter = 0; counter < 8; counter++)
    {
        if ((b & 1) == 1)
            p ^= a;
        hi_bit_set = (a & 0x80);
        a <<= 1;
        if (hi_bit_set == 0x80)
            a ^= 0x1b;
        b >>= 1;
    }
    return p;
}

__device__ void mixColumn(unsigned char *column)
{
    unsigned char cpy[4];
    int i;
    for (i = 0; i < 4; i++)
    {
        cpy[i] = column[i];
    }
    column[0] = galois_multiplication(cpy[0], 2) ^
                galois_multiplication(cpy[3], 1) ^
                galois_multiplication(cpy[2], 1) ^
                galois_multiplication(cpy[1], 3);

    column[1] = galois_multiplication(cpy[1], 2) ^
                galois_multiplication(cpy[0], 1) ^
                galois_multiplication(cpy[3], 1) ^
                galois_multiplication(cpy[2], 3);

    column[2] = galois_multiplication(cpy[2], 2) ^
                galois_multiplication(cpy[1], 1) ^
                galois_multiplication(cpy[0], 1) ^
                galois_multiplication(cpy[3], 3);

    column[3] = galois_multiplication(cpy[3], 2) ^
                galois_multiplication(cpy[2], 1) ^
                galois_multiplication(cpy[1], 1) ^
                galois_multiplication(cpy[0], 3);
}

__device__ void mixColumns(unsigned char *state)
{
    int i, j;
    unsigned char column[4];

    /* iterate over the 4 columns */
    for (i = 0; i < 4; i++)
    {
        /* construct one column by iterating over the 4 rows */
        for (j = 0; j < 4; j++)
        {
            column[j] = state[(j * 4) + i];
        }

        /* apply the mixColumn on one column */
        mixColumn(column);

        /* put the values back into the state */
        for (j = 0; j < 4; j++)
        {
            state[(j * 4) + i] = column[j];
        }
    }
}

__device__ void aes_round(unsigned char *state, unsigned char *roundKey, unsigned char *sbox)
{
    subBytes(state, sbox);
    shiftRows(state);
    mixColumns(state);
    addRoundKey(state, roundKey);
}

__device__ void createRoundKey(unsigned char *expandedKey, unsigned char *roundKey)
{
    int i, j;
    /* iterate over the columns */
    for (i = 0; i < 4; i++)
    {
        /* iterate over the rows */
        for (j = 0; j < 4; j++)
            roundKey[(i + (j * 4))] = expandedKey[(i * 4) + j];
    }
}

__global__ void aes_main(unsigned char *input, unsigned char *output, unsigned char *expandedKey, int nbrRounds, unsigned char *sbox, int msg_length)
{
    int id = threadIdx.x;
    int blockId = blockIdx.x;

    __shared__ unsigned char d_sbox[256];
    __shared__ unsigned char d_expandedKey[176];

    if(id < 256) {
        d_sbox[id] = sbox[id];
    }

    if(id < 176) {
        d_expandedKey[id] = expandedKey[id];
    }

    __syncthreads();

    if ((id + 16) <= msg_length) {
        int i;

        unsigned char state[16];
        for (i = 0; i < 4; i++)
        {
            for (int j = 0; j < 4; j++)
                state[(i + (j * 4))] = input[(blockId * msg_length) + (16 * id) + ((i * 4) + j)];
        }

        i = 0;
        unsigned char roundKey[16];

        createRoundKey(d_expandedKey, roundKey);
        addRoundKey(state, roundKey);

        for (i = 1; i < nbrRounds; i++)
        {
            createRoundKey(d_expandedKey + 16 * i, roundKey);
            aes_round(state, roundKey, d_sbox);
        }

        createRoundKey(d_expandedKey + 16 * nbrRounds, roundKey);
        subBytes(state, d_sbox);
        shiftRows(state);
        addRoundKey(state, roundKey);

        for (i = 0; i < 4; i++)
        {
            for (int j = 0; j < 4; j++)
                output[(blockId * msg_length) + (16 * id) + ((i * 4) + j)] = state[(i + (j * 4))];
        }
    }
}

char aes_encrypt(unsigned char *input,
                 unsigned char *output,
                 unsigned char *key,
                 enum keySize size,
                 int num_msgs,
                 int msg_length)
{

    unsigned char *d_sbox;
    unsigned char *d_input;
    unsigned char *d_output;
    unsigned char *d_expandedKey;

    cudaMalloc((void **) &d_sbox, 256);
    cudaMemcpy(d_sbox, sbox, 256, cudaMemcpyHostToDevice);

    cudaMalloc((void **) &d_input, num_msgs*msg_length);
    cudaMalloc((void **) &d_output, num_msgs*msg_length);
    cudaMemcpy(d_input, input, num_msgs*msg_length, cudaMemcpyHostToDevice);

    /* the expanded keySize */
    int expandedKeySize;

    /* the number of rounds */
    int nbrRounds;

    /* the expanded key */
    unsigned char *expandedKey;

    /* set the number of rounds */
    switch (size)
    {
    case SIZE_16:
        nbrRounds = 10;
        break;
    case SIZE_24:
        nbrRounds = 12;
        break;
    case SIZE_32:
        nbrRounds = 14;
        break;
    default:
        return UNKNOWN_KEYSIZE;
        break;
    }

    expandedKeySize = (16 * (nbrRounds + 1));
    if ((expandedKey = (unsigned char*)(malloc(expandedKeySize * sizeof(char)))) == NULL)
    {
        return MEMORY_ALLOCATION_PROBLEM;
    }

    /* Set the block values, for the block:
     * a0,0 a0,1 a0,2 a0,3
     * a1,0 a1,1 a1,2 a1,3
     * a2,0 a2,1 a2,2 a2,3
     * a3,0 a3,1 a3,2 a3,3
     * the mapping order is a0,0 a1,0 a2,0 a3,0 a0,1 a1,1 ... a2,3 a3,3
     */

    /* expand the key into an 176, 208, 240 bytes key */
    expandKey(expandedKey, key, size, expandedKeySize);
    cudaMalloc((void**) &d_expandedKey, 176);
    cudaMemcpy(d_expandedKey, expandedKey, 176, cudaMemcpyHostToDevice);

    /* encrypt the block using the expandedKey */
    float time;
    cudaEvent_t start, stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    aes_main<<<num_msgs, 1024>>>(d_input, d_output, d_expandedKey, nbrRounds, d_sbox, msg_length);
    cudaDeviceSynchronize();

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);

    printf("Time taken by encrypt on GPU:  %10.6f microseconds \n", time*1000);

    cudaEventRecord(start, 0);
    cudaMemcpy(output, d_output, num_msgs*msg_length, cudaMemcpyDeviceToHost);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);

    printf("Time taken by CUDA memcpy:  %10.6f microseconds \n", time*1000);

    return 0;
}

int main(int argc, char *argv[])
{
    // the cipher key
    unsigned char key[16] = {'k', 'k', 'k', 'k', 'e', 'e', 'e', 'e', 'y', 'y', 'y', 'y', '.', '.', '.', '.'};

    // the plaintext
    int msg_length = 64;
    int num_msgs = 64;
    unsigned char plaintext[num_msgs*msg_length];
    for(int i = 0; i < num_msgs; i++) {
        for(int j = 0; j < (msg_length); j++)
            plaintext[i * msg_length + j] = '0' + (j % 10);
    }

    // the ciphertext
    unsigned char ciphertext[num_msgs*msg_length];

    // the decrypted text
    // unsigned char decryptedtext[msg_length];

    int i;

    printf("\nCipher Key:\n");
    for (i = 0; i < 16; i++)
    {
        printf("%2.2x%c", key[i], ((i + 1) % 16) ? ' ' : '\n');
    }

    printf("\nPlaintext:\n");
    for (i = 0; i < msg_length; i++)
    {
        printf("%2.2x%c", plaintext[i], ((i + 1) % 16) ? ' ' : '\n');
    }

    // AES Encryption
    aes_encrypt(plaintext, ciphertext, key, SIZE_16, num_msgs, msg_length);

    printf("\nCiphertext:\n");
    for (i = msg_length; i < 2*msg_length; i++)
    {
        printf("%2.2x%c", ciphertext[i], ((i + 1) % 16) ? ' ' : '\n');
    }

    return 0;
}