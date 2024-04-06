
PlayField_t .struct 
    playField .fill 16
.ends


playfield .namespace

PLAY_FIELD .dstruct PlayField_t

init
    jsr setDefined
    jsr sprites.init
    rts


; set all values in playing field to zero
clear
    ldx #0
    lda #0
_loop
    sta PLAY_FIELD.playField,x
    inx
    cpx #16
    bne _loop
    rts

INIT_VALUES .byte 1,2,3,4, 5,6,7,8, 9,10,11,12, 13,14,15,0

setDefined
    ldx #0
_loop
    lda INIT_VALUES, x
    sta PLAY_FIELD.playField,x
    inx
    cpx #16
    bne _loop
    rts


TEMP .byte ?
; search value given in accu in playfield
; Return first found position in x register or 16 if not found
findValue
    ldx #0
    sta TEMP
_loop
    lda PLAY_FIELD.playField,x
    cmp TEMP
    beq _done
    inx
    cpx #16
    bne _loop
_done
    rts


SCRATCH .byte $00
;--------------------------------------------------
; calcPlayFieldOffset calculates the offset of the position x,y 
; 
; INPUT:  x-pos (0-3) in register X, y-pos (0-3) in accu
;         X and A are not changed by this call
; OUTPUT: offset in register Y
; --------------------------------------------------
calcPlayFieldOffset
    pha            ; save accu
    asl            ; * 2
    asl            ; * 2
    stx SCRATCH    ; x-pos in temp memory
    clc
    adc SCRATCH    ; add x-pos to row base address
    tay            ; move result to y
    pla            ; restore accu
     
    rts


;--------------------------------------------------
; calcPlayFieldOffsetTransposed calculates the offset of the position y,x 
; 
; INPUT:  x-pos (0-3) in register X, y-pos (0-3) in accu
;         X and A are not changed by this call
; OUTPUT: offset in register Y
; --------------------------------------------------
calcPlayFieldOffsetTransposed
    sta SCRATCH    ; save y-pos
    phx            ; save x-pos
    txa            ; calc x-pos * 4
    asl            ; * 2
    asl            ; * 2
    clc
    adc SCRATCH    ; add y-pos to row base address
    tay            ; move result to y
    plx            ; restore x register
    lda SCRATCH

    rts

COUNT_X .byte ?
COUNT_Y .byte ?
draw
    lda #18
    sta RECT_PARAMS.xpos
    lda #9
    sta RECT_PARAMS.ypos
    lda #4*9
    sta RECT_PARAMS.lenx
    lda #4*9
    sta RECT_PARAMS.leny
    lda #DRAW_FALSE
    sta RECT_PARAMS.overwrite
    lda GLOBAL_STATE.globalCol
    sta RECT_PARAMS.col
    jsr txtrect.drawRect

    stz COUNT_X
    stz COUNT_Y
_placeSprite
    ldx COUNT_X
    lda COUNT_Y
    jsr calcPlayFieldOffset
    lda PLAY_FIELD.playField, Y
    beq _noSprite
    dea
    jsr sprites.callSetSpritePointer
    ldx COUNT_X
    ldy COUNT_Y
    jsr sprites.setPosition
    jsr sprites.on
_noSprite
    inc COUNT_X
    lda COUNT_X
    cmp #4
    bne _placeSprite
    stz COUNT_X
    inc COUNT_Y
    lda COUNT_Y
    cmp #4
    bne _placeSprite

    rts

.endnamespace