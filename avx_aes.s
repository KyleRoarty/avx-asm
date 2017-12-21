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
