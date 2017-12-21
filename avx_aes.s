.text

/* In:
/*		rsi; Address of where previous expanded key was inserted
/*		xmm0; previous (expanded) key
/*		xmm1; Generated round (?)
/*		xmm4; .L__mask
/* Out:
/*		Null. Stores expanded key in 16(rsi)
/* Description:
/*		Takes previous key, copies it. Permutes the clone according to
/*		.L_mask, and xors with original key 3x.
/*		Then, shuffles generated round (?) with 0xff, and xors key.
/*		Store modified key into 16(rsi)
/*/
.type keyexpansion,@function
keyexpansion:
#	add		$16, %rsi
#	vpshufd	%0xff, %xmm1, %xmm1

	vmovdqa	%xmm0, %xmm3

	vpshufb	%xmm4, %xmm3, %xmm3
	vpxor	%xmm3, %xmm0, %xmm0
	vpshufb	%xmm4, %xmm3, %xmm3
	vpxor	%xmm3, %xmm0, %xmm0
	vpshufb	%xmm4, %xmm3, %xmm3
	vpxor	%xmm3, %xmm0, %xmm0

	vpshufd	%0xff, %xmm1, %xmm1
	vpxor	%xmm1, %xmm0, %xmm0

	add		$16, %rsi
	vmovdqu	%xmm0, (%rsi)
	ret

/* In:
/*		rdi; Address of initial key
/*		rsi; Address of initial location for round key
/* Out:
/*		Null. Places expanded key in (%rsi)
/* Description:
/*		Used to generate expanded encryption key using Rijndael key schedule
/*		https://en.wikipedia.org/wiki/Rijndael_key_schedule
/*		.L_mask is placed after the code, and referenced indirectly using rip
/*/
.global expandkey128
.type expandkey128,@function
expandkey128:
	vmovdqu		(%rdi), %xmm0			# vmovdqu: Moves packed integers
	vmovdqu		%xmm0, (%rsi)			# Double Quadword Unaligned
	vmovdqu		.L__mask(%rip), %xmm4	# 16 8-bit integers

	vaeskeygenassist $0x1, %xmm0, %xmm1		# Constants generated from the
	call keyexpansion						# Rijndael key schedule
	vaeskeygenassist $0x2, %xmm0, %xmm1		# Rcon function
	call keyexpansion
	vaeskeygenassist $0x4, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x8, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x10, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x20, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x40, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x80, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x1b, %xmm0, %xmm1
	call keyexpansion
	vaeskeygenassist $0x36, %xmm0, %xmm1
	call keyexpansion

	ret
.align 32
.L__mask:
.quad 0x3020100ffffffff
.quad 0xb0a090807060504


/* In:
/*		rdi; pointer to plaintext data
/*		rsi; pointer to expanded round key
/*		rdx/edx; Number of rounds of encryption to do
/* Out:
/*		Null; Encrypted data stored in rdi/plaintext data location
/*/
.global aes_encrypt_asm
.type aes_encrypt_asm,@function
aes_encrypt_asm:
	vmovdqu		(%rdi), %xmm0		# Input variable parsing
	vmovdq		(%rsi), %xmm1		#
	movl		%edx, %ecx			#

	vpxor		%xmm1, %xmm0, %xmm0	# Addroundkey, literally turn data to
	add			$16, %rsi			# 4x4 grids, xor grids
									# Done here b/c first part of round
									# is the plain key

	dec		$1, %ecx			# Sub 1 because last round is special

aes_round_enc:
	vmovdqu		(%rsi), %xmm1				# Get next part of round key
	vaesenc		%xmm1, %xmm0, %xmm0			# Encrypt using that part
	add			$16, %rsi
	dec			%ecx
	jne			aes_round_enc:

enc_last_round:
	vmovdqu		(%rsi), %xmm1
	vaesenclast %xmm1, %xmm0, %xmm0
	vmovdqu		%xmm0, (%rdi)

	ret

/* In:
/*		rdi; Pointer to encrypted data
/*		rsi; Pointer to expanded round key
/*		rdx/edx; Number of rounds of decryption
/* Out:
/*		Null; Decrypted data stored in rdi/encrypted data location
/*/
.global aes_decrypt_asm
.type aes_decrypt_asm,@function
aes_decrypt_asm:
	vmovdqu		(%rdi),%xmm0

	movl		%edx, %ecx			# Create iterator
	imull		$16, %edx, %edx		#
	addl		%rdx, %rsi			# Start at last round key part, not first
	vmovdqu		(%rsi), %xmm1
	pxor		%xmm1, %xmm0		# Why pxor and not vpxor?

	subl		$16, %rsi
	dec			%ecx

aes_round_dec:
	vmovdqu		(%rsi), %xmm1
	vaesimc		%xmm1, %xmm1		# InvMinColumn transformation
									# Done on all but first and last round
									# keys before decryption step
	vaesdec		%xmm1, %xmm0, %xmm0
	subl		$16, %rsi
	dec			%ecx
	jne			aes_round_dec

dec_last_round:
	vmovdqu		(%rsi), %xmm1
	vaesdeclast	%xmm1, %xmm0, %xmm0
	vmovdqu		%xmm0, (%rdi)

	ret
