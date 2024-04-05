

SPR_SIZE_8 = 64 | 32
SPR_SIZE_16 = 64
SPR_SIZE_24 = 32
SPR_SIZE_32 = 0

SPR_LAYER_0 = 0
SPR_LAYER_1 = 8
SPR_LAYER_2 = 16
SPR_LAYER_3 = 16 | 8

SPR_LUT_0 = 0
SPR_LUT_1 = 2
SPR_LUT_2 = 4
SPR_LUT_3 = 2 | 4

SPR_ENABLE = %00000001

SpriteBlock_t .struct 
    control .byte ?
    addr .long ?
    xpos .word ?
    ypos .word ?
.endstruct


setSpritePtr .macro sprnum
    lda #\sprnum
    jsr callSetSpritePointer
.endmacro

sprites .namespace

BIT_TEXT = 1
BIT_OVERLY = 2
BIT_GRAPH = 4
BIT_BITMAP = 8
BIT_TILE = 16
BIT_SPRITE = 32
BIT_GAMMA = 64
BIT_X = 128

BIT_CLK_70 = 1
BIT_DBL_X = 2
BIT_DBL_Y = 4
BIT_MON_SLP = 8 
BIT_FON_OVLY = 16
BIT_FON_SET = 32

activate
    lda #BIT_TEXT | BIT_OVERLY | BIT_SPRITE | BIT_GRAPH
    sta $D000
    lda #0
    sta $D001
    rts


deactivate
    lda #BIT_TEXT
    sta $D000
    lda #$00
    sta $D001    
    rts


init
    ; set bitmap data for all sprites
    ldy #0                                              ; sprite block  0..14
    ldx #1                                              ; sprite number 1..15
_sprLoop
    tya
    jsr callSetSpritePointer
    txa
    jsr setBitmapAddr
    inx
    iny
    cpy #15
    bne _sprLoop

    ; Activate sprite layer
    jsr activate
    rts


; accu has to contain contain 0-15 
; After routine SPRITE_PTR1  is set to address of corresponding sprite block
callSetSpritePointer
    asl
    asl
    asl
    sta SPRITE_PTR1
    lda #$D9
    sta SPRITE_PTR1+1
    rts

; SPRITE_PTR1 has to be set to correct block
on
    lda #SPR_SIZE_32 | SPR_LAYER_0 | SPR_LUT_0 | SPR_ENABLE
    sta (SPRITE_PTR1)
    rts

; SPRITE_PTR1 has to be set to correct block
off
    lda #SPR_SIZE_32 | SPR_LAYER_0 | SPR_LUT_0 
    sta (SPRITE_PTR1)
    rts    


SPR_DATA_ADDR
.word 0
.word 1 * 1024
.word 2 * 1024
.word 3 * 1024
.word 4 * 1024
.word 5 * 1024
.word 6 * 1024
.word 7 * 1024
.word 8 * 1024
.word 9 * 1024
.word 10 * 1024
.word 11 * 1024
.word 12 * 1024
.word 13 * 1024
.word 14 * 1024

; SPRITE_PTR1 has to be set to correct block
; accu has to contain the sprite number 1-15, i.e. the value on the playing field
setBitmapAddr    
    phx
    phy    
    dea
    asl
    tax
    ldy #SpriteBlock_t.addr
    lda SPR_DATA_ADDR, x
    sta (SPRITE_PTR1), y
    inx
    iny
    lda SPR_DATA_ADDR, x
    sta (SPRITE_PTR1), y
    iny
    lda #2
    sta (SPRITE_PTR1), y
    jsr on
    ply
    plx
    rts


X_OFFSET = 79 + 32
Y_OFFSET = 41 + 32

XPOSITIONS
.word X_OFFSET
.word X_OFFSET + 1 * (32 + 4)
.word X_OFFSET + 2 * (32 + 4)
.word X_OFFSET + 3 * (32 + 4)

YPOSITIONS
.word Y_OFFSET
.word Y_OFFSET + 1 * (32 + 4)
.word Y_OFFSET + 2 * (32 + 4)
.word Y_OFFSET + 3 * (32 + 4)


.endnamespace