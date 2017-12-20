.data

.align 32
.L__mask:
.quad 0x3020100ffffffff
.quad 0xb0a090807060504

.text

/* In:
/*		rsi; Address of where previous expanded key was inserted
/*		xmm0; previous (expanded) key
/*		xmm1; Generated round (?)
/*		xmm4; .L__mask (Why 3-2-1-0-f-f-f-f-f-f-f-f-b-a-9-8-7-6-5-4?)
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
