#include <stdio.h>

int main( ){
    unsigned char key[16] = {0x00  ,0x01  ,0x02  ,0x03  ,0x04  ,0x05  ,0x06  ,0x07,
                             0x08  ,0x09  ,0x0a  ,0x0b  ,0x0c  ,0x0d  ,0x0e  ,0x0f};
    unsigned char ptext[] = {0x00  ,0x11  ,0x22  ,0x33  ,0x44  ,0x55  ,0x66  ,0x77,
                             0x88  ,0x99  ,0xaa  ,0xbb  ,0xcc  ,0xdd  ,0xee  ,0xff};
    unsigned char RoundKey[240];
    int Nr = 10;
    for(int i = 0; i < sizeof(key)/sizeof(unsigned char); i++){
        printf("%02X",key[i]);
    }
    printf("\n");
    for(int i = 0; i < sizeof(ptext)/sizeof(unsigned char); i++){
        printf("%02X",ptext[i]);
    }
    printf("\n");
    expandkey128(key,RoundKey);
    aes_encrypt_asm(ptext,RoundKey,Nr);
    for(int i = 0; i < sizeof(ptext)/sizeof(unsigned char); i++){
        printf("%02X",ptext[i]);
    }
    printf("\n");
    aes_decrypt_asm(ptext,RoundKey,Nr); // should get back the original text
    for(int i = 0; i < sizeof(ptext)/sizeof(unsigned char); i++){
        printf("%02X",ptext[i]);
    }
    printf("\n");
}
