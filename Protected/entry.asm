; This entry point
[ORG 0x0500]

; Initially, I have to use 16 bit code as CPU is in Real Mode

[BITS 16]
section .text
global entry
entry:

; Display a blinking white-on-blue 'D'
mov ax,0B800h
mov es,ax           ; This line is causing Guru Mediatation if DS is used instead of ES
mov word [es:0000h],9F44h


; Enable A20
	cli				
n5:	in	al, 0x64		
	test	al, 2
	jnz	n5
	mov	al, 0xD1
	out	0x64, al
n6:	in	al, 0x64
	test	al, 2
	jnz	n6
	mov	al, 0xDF
	out	0x60, al
	
	; I have to explicitly mention CS register in LGDT as implicit reference would mean DS register which is till now 0x07C0
	; as set by BIOS during bootloading.Otherwise, it'll cause a triple fault to occur.
	
    lgdt    [cs:gdtinfo];Load GDT
	mov	ecx, CR0		;Switch to protected mode
	inc	ecx
	mov	CR0, ecx
	mov	ax, (flat_data-gdt_table)	; Selector for 4Gb data seg
	mov	ds, ax			
	mov	es, ax			
	mov	fs, ax			
	mov gs, ax			
	jmp dword (flat_code-gdt_table):pmode
	pmode:

; From now onwards, I can use 32 bit code as CPU is in Protected mode
	
[BITS 32]	
	
mov word [0B80A0h],9F45h
extern main
call main
jmp $


gdtinfo:

dw	gdtlength
dd	gdt_table

;********* GDT TABLE *********

gdt_table:

; NULL Descriptor
	dw 0		; limit 15:0
	dw 0		; base 15:0
	db 0		; base 23:16
	db 0		; type
	db 0		; limit 19:16, flags
	db 0		; base 31:24
	
; CODE	Segment Descriptor
flat_code:
	dw 0FFFFh	; limit (0-15)
	dw 0		; base (0-15)
	db 0		; base (16-23)
	db 9Ah		; present,ring 0,code,non-conforming,readable,(present,DPL,Desc type(code/data=1,sys=0),TYPE)
	db 0CFh		; page-granular (4 gig limit), 32-bit
	db 0		; base 31:24

; DATA Segment Descriptor
flat_data:
	dw 0FFFFh	; limit (0-15)
	dw 0		; base (0-15)
	db 0		; base (16-23)
	db 92h		; present, ring 0, data, expand-up, writable
	db 0CFh		; page-granular (4 gig limit), 32-bit
	db 0		; base 31:24

	
gdtlength equ $ - gdt_table - 1

;********* END GDT TABLE ***********
