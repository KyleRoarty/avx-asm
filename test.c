#include <stdio.h>

extern void expandkey128(unsigned char *, unsigned char *);
extern void aes_encrypt_asm(unsigned char *, unsigned char *, int);
extern void aes_decrypt_asm(unsigned char *, unsigned char *, int);

// len = sizeof(char_str). Normalized inside of function
void printCharStr(unsigned char *char_str, int len){
    for(int i = 0; i < len/sizeof(unsigned char); i++){
        printf("%02X", char_str[i]);
    }
    printf("\n");

    return;
}

int main( ){
    unsigned char key[16] = {0x00  ,0x01  ,0x02  ,0x03  ,0x04  ,0x05  ,0x06  ,0x07,
                             0x08  ,0x09  ,0x0a  ,0x0b  ,0x0c  ,0x0d  ,0x0e  ,0x0f};
    unsigned char ptext[] = {0x00  ,0x11  ,0x22  ,0x33  ,0x44  ,0x55  ,0x66  ,0x77,
                             0x88  ,0x99  ,0xaa  ,0xbb  ,0xcc  ,0xdd  ,0xee  ,0xff};
    unsigned char RoundKey[240];
    int Nr = 10;

    printCharStr(key, sizeof(key));
    printCharStr(ptext, sizeof(ptext));

    expandkey128(key,RoundKey);
    aes_encrypt_asm(ptext,RoundKey,Nr);
    printCharStr(ptext, sizeof(ptext));

    aes_decrypt_asm(ptext,RoundKey,Nr); // should get back the original text
    printCharStr(ptext, sizeof(ptext));

}
