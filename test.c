#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

extern void expandkey128(unsigned char *, unsigned char *);
extern void aes_encrypt_asm(unsigned char *, unsigned char *, unsigned char *, int);
extern void aes_decrypt_asm(unsigned char *, unsigned char *, unsigned char *, int);

// len = sizeof(char_str). Normalized inside of function
void printCharStr(unsigned char *char_str, int len){
    for(int i = 0; i < len/sizeof(unsigned char); i++){
        printf("%02X", char_str[i]);
    }
    printf("\n");

    return;
}

void printPointStr(unsigned char *char_str, int len){
    for(int i = 0; i < len; i++){
        printf("%02X", char_str[i]);
    }
    printf("\n");

    return;
}

int main( ){
    unsigned char key[16] = {0x00  ,0x01  ,0x02  ,0x03  ,0x04  ,0x05  ,0x06  ,0x07,
                             0x08  ,0x09  ,0x0a  ,0x0b  ,0x0c  ,0x0d  ,0x0e  ,0x0f};

    unsigned char ptext[] = {0x00  ,0x11  ,0x22  ,0x33  ,0x44  ,0x55  ,0x66  ,0x77,
                             0x88  ,0x99  ,0xaa  ,0xbb  ,0xcc  ,0xdd  ,0xee  ,0xff,
                             0x00  ,0x11};
    unsigned char RoundKey[240];
    unsigned char *res, *padded_ptext, *dec_ptext;
    int Nr = 10;

    int ptext_len = sizeof(ptext)/sizeof(unsigned char);
    int ptext_len_ceil = 16*ceil(ptext_len/16.0);

    res = calloc(ptext_len_ceil, sizeof(unsigned char));
    dec_ptext = calloc(ptext_len_ceil, sizeof(unsigned char));
    //Pad ptext with 0's
    padded_ptext = calloc(ptext_len_ceil, sizeof(unsigned char));
    memcpy(padded_ptext, ptext, 18);


    printCharStr(key, sizeof(key));
    printPointStr(padded_ptext, ptext_len_ceil);


    expandkey128(key,RoundKey);

    for(int i = 0; i < ptext_len_ceil; i += 16){
        aes_encrypt_asm(padded_ptext+i, RoundKey, res+i, Nr);
    }
    printPointStr(res, ptext_len_ceil);

    for(int i = 0; i < ptext_len_ceil; i += 16){
        aes_decrypt_asm(res+i, RoundKey, dec_ptext+i, Nr);
    }
    printPointStr(dec_ptext, ptext_len_ceil);

    free(padded_ptext);
    free(dec_ptext);
    free(res);

}
