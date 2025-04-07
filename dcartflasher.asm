;-----------------------------------------------------------------------
;
; DCart Flasher - Main Menu
; (c)2025 GienekP
;
;-----------------------------------------------------------------------
TMP		= $A0
;----------------
STARTAD	= $2E00
READNO	= $37E8
FLASHPR	= $37F0
LASTAD	= $37F8
;----------------
RTCLOK	= $12
CRITIC  = $42
ATRACT	= $4D
ATRMSK	= $4E
DMACTLS	= $022F
DLPTRS	= $0230
COLDST	= $0244
GTICTLS	= $026F
COLPM0S	= $02C0
COLPM1S	= $02C1
COLPM2S	= $02C2
COLPM3S	= $02C3
COLPF0S	= $02C4
COLPF1S	= $02C5
COLPF2S	= $02C6
COLPF3S	= $02C7
COLBAKS	= $02C8
HLPFLG	= $02DC
GINTLK  = $03FA
TRIG3   = $D013
PMCTL	= $D01D
CONSOL  = $D01F
HPOSP0	= $D000
HPOSP1	= $D001
HPOSP2	= $D002
HPOSP3	= $D003
PMBASE	= $D407
SIZEP0	= $D008
SIZEP1	= $D009
SIZEP2	= $D00A
SIZEP3	= $D00B
COLPF0	= $D016
RANDOM	= $D20A
DMACTL	= $D400
WSYNC	= $D40A
VCOUNT  = $D40B
RESETCD = $E477
;-----------------------------------------------------------------------
		OPT h+
		ORG STARTAD
;----------------
SUM		:64 dta $00
XOR		:64 dta $00
;----------------
TITLE	:32	dta d' '
;----------------
BAR		dta d' dcart flasher  '*
PREPARE	dta d'Prepare:                        '
READY	dta d'Ready:                          '
		dta d'Ready:                SST39SF040'
SCANING	dta d'Scan:                           '
		dta d'Scan:                 SST39SF040'
VERIFIN	dta d'Verify:                         '
		dta d'Verify:               SST39SF040'
READING	dta d'Read:                           '
		dta d'Read:                 SST39SF040'
WRITING	dta d'Write:                          '
		dta d'Write:                SST39SF040'
FORMATG	dta d'Format:                         '
		dta d'Format:               SST39SF040'
DONEMSG	dta d'Done:                           '
		dta d'Done:                 SST39SF040'	
;----------------
KEYS	dta $48, d' Help '*, $C8, d' - Scan banks           '
		dta $48, d'Start '*, $C8, d' - Full flash           '
		dta $48, d'Select'*, $C8, d' - Only verify          ' 
		dta $48, d'Option'*, $C8, d' - Erase and blank check'
		dta $48, d'Reset '*, $C8, d' - CART ON & RESET      '
;----------------
IMAGE	dta d'################'
		dta d'################'
		dta d'################'
		dta d'################'
;----------------
RUNAD	lda #$00
		sta DMACTLS
		sta DMACTL
		sta ATRACT
		jsr CARTOFF
		ldx #$01
		stx COLDST
		inx
		stx PMCTL
		lda #>PMSTRT
		sta PMBASE
		lda #04
		jsr SETPLCO
		lda #$03
		sta SIZEP0
		sta SIZEP1
		sta SIZEP2
		sta SIZEP3
		lda #$08
		sta GTICTLS
		lda #$40
		sta HPOSP0
		lda #$60
		sta HPOSP1
		lda #$80
		sta HPOSP2
		lda #$A0
		sta HPOSP3
		lda #<MENU
		sta DLPTRS
		lda #>MENU
		sta DLPTRS+1
		lda #$00
		sta COLBAKS
		lda #$0A
		sta COLPF0S
		lda #$EC
		sta COLPF1S
		lda #$00
		sta COLPF2S
		lda #$8A
		sta COLPF3S
		lda #$39
		sta DMACTLS
		jsr CLRRAM
;----------------
BACK	jsr	DETECT
		jsr	READYMN
;--------
MENULOP	lda #$00
		sta ATRACT
		lda HLPFLG
@		cmp #$11
		bne @+
		lda #$FF
		sta HLPFLG
		jsr SCAN
		jmp BACK
;--------
@		lda CONSOL
		and #$07
		cmp #$03
		bne @+
		jsr FORMAT
		jmp BACK
;--------
@		cmp #$05
		bne @+
		jmp VERIFY
;--------
@		cmp #$06
		bne @+
		jmp WRITE	
;--------		
@		jmp MENULOP
;----------------
AGAIN	jsr SHOWIMG
		jsr CARTOFF
		lda MODVER
@		bne	@-		
		rts
;----------------
SETPLCO	sta COLPM0S
		sta COLPM1S
		sta COLPM2S
		sta COLPM3S
		rts
;----------------
SHOWMSG	stx MSG+1
		sty MSG+2
		lda MFDTCT
		beq @+
		clc
		lda #32
		add MSG+1
		sta MSG+1
		bcc	@+
		inc MSG+2
@		rts
;----------------
SHOWIMG	sta IMAGE,x
		rts
;----------------
SETBANK	lda #$40
@		cmp VCOUNT
		bne @-
		inc CRITIC		
		txa
		sta $D500
		sta $D500,x
		sta BANKNO
		lda TRIG3
		sta GINTLK
		dec CRITIC
		rts
;----------------
CARTOFF	lda #$40
@		cmp VCOUNT
		bne @-
		inc CRITIC		
		lda #$FF
		sta $D500
		sta $D50F
		sta $D580
		sta $D5FF
		lda TRIG3
		sta GINTLK
		dec CRITIC
		rts
;----------------
CLRRAM	lda #$00
		sta TMP
		lda #$40
		sta TMP+1
loopcr	ldy #$00
@		lda #$00
		sta (TMP),y
		iny
		bne @-
		inc TMP+1
		lda TMP+1
		cmp #$C0
		bne loopcr
		rts
;----------------
READYMN	ldx #$00
		jsr SETBANK
		ldx #<READY
		ldy #>READY
		jsr SHOWMSG
		lda #04
		jsr SETPLCO
		rts
;----------------
SCANBNK	lda #$00
		sta TMP
		lda #$A0
		sta TMP+1
SBLS	ldy #$00
SBL		lda (TMP),y
		cmp	#$FF
		beq @+
		lda #$01
		sta DIFFF
@		lda (TMP),y
		cmp #$00
		beq @+
		lda #$01
		sta DIF00
@		iny
		bne SBL
		inc TMP+1
		lda TMP+1
		cmp #$C0
		bne SBLS
		rts
;----------------
SCANMID	ldx #$00
SCNLOOP	lda #$00
		sta DIFFF
		sta DIF00
		jsr SETBANK
		lda #$0A
		jsr SHOWIMG
		jsr SCANBNK
		lda DIFFF
		bne @+
		lda #$26
		jmp	SCRD
@		lda DIF00
		bne	@+
		lda #$10
		jmp	SCRD		
@		lda #$24
SCRD	jsr SHOWIMG
		inx
		cpx #$40
		bne SCNLOOP
		rts
;----------------
SCAN	ldx #<SCANING
		ldy #>SCANING
		jsr SHOWMSG
		lda #$72
		jsr SETPLCO
		ldx #10
@		lda #$FF
		sta MRKR0+11,x
		sta MRKR1+11,x
		sta MRKR2+11,x
		sta MRKR3+11,x
		dex
		bne @-
		jsr SCANMID
		ldx #10
@		lda #$00
		sta MRKR0+11,x
		sta MRKR1+11,x
		sta MRKR2+11,x
		sta MRKR3+11,x
		dex
		bne @-
		rts
;----------------
FORMAT	ldx #<FORMATG
		ldy #>FORMATG
		jsr SHOWMSG
		lda #$42
		jsr SETPLCO
		ldx #10
@		lda #$FF
		sta MRKR0+44,x
		sta MRKR1+44,x
		sta MRKR2+44,x
		sta MRKR3+44,x
		dex
		bne @-
		jsr FRMTCMD
		jsr SCANMID
		ldx #10
@		lda #$00
		sta MRKR0+44,x
		sta MRKR1+44,x
		sta MRKR2+44,x
		sta MRKR3+44,x
		dex
		bne @-
		rts
;----------------
VERIFY	ldx #<VERIFIN
		ldy #>VERIFIN
		jsr SHOWMSG
		lda #$A2
		jsr SETPLCO
		ldx #10
@		lda #$FF
		sta MRKR0+33,x
		sta MRKR1+33,x
		sta MRKR2+33,x
		sta MRKR3+33,x
		dex
		bne @-
		lda #$00
		sta MODVER
		rts
		; CONTINUE XEX
;----------------
WRITE	ldx #<WRITING
		ldy #>WRITING
		jsr SHOWMSG
		lda #$22
		jsr SETPLCO
		ldx #10
@		lda #$FF
		sta MRKR0+22,x
		sta MRKR1+22,x
		sta MRKR2+22,x
		sta MRKR3+22,x
		dex
		bne @-
		lda #$01
		sta MODVER
		jsr FRMTCMD
		rts
		; CONTINUE XEX
;----------------
SETRNO	lda #$00
		sta ATRACT
		lda SAVBNO
		cmp #$FF
		beq @+
		and #$7F
		sta BANKNO
		lda #$FF
		sta SAVBNO
		lda #$32
		ldx BANKNO
		jsr SHOWIMG
@		rts
;----------------
FLASH	lda #$00
		sta TMP
		sta CRCSUM
		sta CRCXOR
		lda #$40
		sta TMP+1
;--------
RDCRC	ldy #$00
@		lda (TMP),y
		tax
		clc
		add CRCSUM
		sta CRCSUM
		txa
		eor CRCXOR
		sta CRCXOR
		iny
		bne @-
		inc TMP+1
		lda TMP+1
		cmp #$60
		bne RDCRC
;--------
		ldx BANKNO
		lda SUM,x
		cmp CRCSUM
		bne READERR
		lda XOR,x
		cmp CRCXOR
		beq @+
;--------
READERR	lda #$25
		ldx BANKNO
		jmp AGAIN
;--------
@		lda MODVER
		beq ONLYVFI
		jsr FLASHCM
;--------
ONLYVFI	lda #$36
		ldx BANKNO
		jsr SHOWIMG
		jsr SETBANK
		lda #$00
		sta TMP
		sta TMP+2
		lda #$A0
		sta TMP+1
		lda #$40
		sta TMP+3		
VFML	ldy #$00
@		lda (TMP+2),y
		cmp (TMP),y
		bne VFERROR
		iny
		bne @-
		inc TMP+3
		inc TMP+1
		lda TMP+1
		cmp #$C0
		bne VFML
		rts
;--------		
VFERROR	jsr SCANBNK
		lda DIFFF
		bne @+
		lda #$26
		jmp	AGAIN
@		lda DIF00
		bne	@+
		lda #$10
		jmp	AGAIN		
@		lda #$24
		jmp AGAIN
;----------------
DETECT	ldx #$00
		jsr SETBANK
		lda #$AA
		sta $D502
		sta $B555	; 1st AA->5555
		lda #$55
		sta $D501
		sta $AAAA	; 2nd 55->2AAA
		lda #$90
		sta $D502
		sta $B555	; 3rd 90->5555
		lda $A001
		cmp #$B7
		bne @+
		inx
@		lda #$F0
		sta $A000
		stx MFDTCT
		rts
;----------------
FRMTCMD	ldx #$00
		jsr SETBANK
;--------
		lda #$AA
		sta $D502
		sta $B555	; 1st AA->5555
		lda #$55
		sta $D501
		sta $AAAA	; 2nd 55->2AAA
		lda #$80
		sta $D502
		sta $B555	; 3rd 80->5555
		lda #$AA
		sta $D502
		sta $B555	; 4th AA->5555
		lda #$55
		sta $D501
		sta $AAAA	; 5tg 55->2AAA
		lda #$10
		sta $D502
		sta $B555	; 6th 10->5555
;--------
		ldx #$00
WAIT1S	lda #$1D
		jsr SHOWIMG
		ldy	#$10
@		cmp VCOUNT
		bne @-
		sta WSYNC
		sta WSYNC
		sta WSYNC
		inx
		cpx #$40
		bne WAIT1S
		rts
;----------------
FLASHCM	lda #$37
		ldx BANKNO
		jsr SHOWIMG
;--------
		lda #$00
		sta TMP
		sta TMP+2
		lda #$A0
		sta TMP+1
		lda #$40
		sta TMP+3
;--------
SAVELP	ldy #$00
@		lda (TMP+2),y
		pha
;--------
		lda #$AA
		sta $D502
		sta $B555	; 1st AA->5555
		lda #$55
		sta $D501
		sta $AAAA	; 2nd 55->2AAA
		lda #$A0
		sta $D502
		sta $B555	; 3rd A0->5555
		txa	
		sta	$D500,x
		pla
		sta (TMP),y
;--------
		sta WSYNC	; 4 x 6.24us
		sta WSYNC
		sta WSYNC
		sta WSYNC
;--------
		iny
		bne @-
		inc TMP+3
		inc TMP+1
		lda TMP+1
		cmp #$C0
		bne SAVELP
		rts
;-----------------------------------------------------------------------
MFDTCT	dta $00
DIFFF	dta $00
DIF00	dta $00
MODVER	dta	$00
CRCSUM	dta $00
CRCXOR	dta $00
BANKNO	dta $00
;-----------------------------------------------------------------------
MENU	dta $70,$70,$70,$70,$70
		dta $47,<BAR,>BAR
		dta $70,$70
MSG		dta $42,<PREPARE,>PREPARE
		dta $46,<TITLE,>TITLE
		dta $70,$40
		dta $46,<IMAGE,>IMAGE
		dta $06,$06,$06
		dta $70,$40
		dta $42,<KEYS,>KEYS
		dta $20,$02,$20,$02,$20,$02,$20,$02
		dta $41,<MENU,>MENU
;-----------------------------------------------------------------------
BEGIN	ldx #10
@		lda #$00
		sta MRKR0+22,x
		sta MRKR1+22,x
		sta MRKR2+22,x
		sta MRKR3+22,x
		sta MRKR0+33,x
		sta MRKR1+33,x
		sta MRKR2+33,x
		sta MRKR3+33,x
		dex
		bne @-
;--------
		jsr READYMN
		ldx #<DONEMSG
		ldy #>DONEMSG
		jsr SHOWMSG
		ldx #250
ENDMSG	lda #$40
@		cmp VCOUNT
		bne @-
		lda #$39
@		cmp VCOUNT
		bne @-
		dex
		bne ENDMSG
;--------					
		jsr CARTOFF
		jsr CLRRAM
		jsr READYMN
		lda #$00
		sta DMACTLS
		sta DMACTL
		sta PMCTL
		lda #$01
		sta COLDST
		lda #$00
		jsr SETPLCO
		lda #$00
		sta COLBAKS
		lda #$0C
		sta COLPF1S
		lda #$00
		sta COLPF2S
		lda #<ANTIC
		sta DLPTRS
		lda #>ANTIC
		sta DLPTRS+1
		lda #$21
		sta DMACTLS
;----------------
@		lda CONSOL
		and #$07
		cmp #$07
		beq @-
		jmp RESETCD
;----------------
ANTIC	:+13 dta $70
		dta $42,<MSGEND,>MSGEND
		dta $41,<ANTIC,>ANTIC
;----------------
MSGEND	dta d' ', $48, d'Start'*, $C8, $48, d'Select'*, $C8, $48, d'Option'*, $C8, $48,  d'Reset'*, $C8, d' '
;-----------------------------------------------------------------------
		ORG READNO
;----------------
SAVBNO	dta	$FF
		jmp SETRNO
;-----------------------------------------------------------------------				
		ORG FLASHPR
;----------------
		jmp FLASH
;-----------------------------------------------------------------------
		ORG LASTAD
;----------------
		jmp BEGIN
;-----------------------------------------------------------------------
.align $0800
PMSTRT	:1133 dta $00
		:32 dta $FF
MRKR0	:224 dta $00
		:32 dta $FF
MRKR1	:224 dta $00
		:32 dta $FF
MRKR2	:224 dta $00
		:32 dta $FF
MRKR3	:115 dta $00		
;-----------------------------------------------------------------------
		INI RUNAD		
;-----------------------------------------------------------------------
