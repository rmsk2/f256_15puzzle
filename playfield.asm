
PlayField_t .struct 
    playField   .fill 16
    offsetEmpty .byte 0
.endstruct


MOVE_UP    = %00000001
MOVE_DOWN  = %00000010
MOVE_LEFT  = %00000100
MOVE_RIGHT = %00001000
MOVE_ALL   = %00001111 
NOT_POSSIBLE = $FF


MoveOffsets_t .struct u, d, l, r, m
    up    .byte \u
    down  .byte \d
    left  .byte \l
    right .byte \r
    moves .byte \m
    pad   .fill 3
.endstruct

playfield .namespace

PLAY_FIELD .dstruct PlayField_t

; initialize playfield
init
    jsr setDefined
    lda #15
    sta PLAY_FIELD.offsetEmpty
    
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
; set all values in playing field to the values given above
setDefined
    ldx #0
_loop
    lda INIT_VALUES, x
    sta PLAY_FIELD.playField,x
    inx
    cpx #16
    bne _loop
    rts


; If the game state is ordered, clear carry upon return
isOrdered
    ldy #0
_test
    lda INIT_VALUES, y
    cmp PLAY_FIELD.playField, y
    bne _doneError
    iny
    cpy #16
    bne _test
    clc
    rts
_doneError
    sec
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


; offset in Accu
; coordinates are returned in y and y
calcPlayFieldCoordinates
    sta SCRATCH
    and #%00000011
    tax
    lda SCRATCH
    and #%00001100
    lsr
    lsr
    tay
    rts


; bitflag in x
; offest returned in y
bitFlagToOffset
    ldy #0
    clc
    txa
_testLoop    
    lsr
    bcs _done
    iny
    bra _testLoop
_done
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
; Draw playing field as a whole
draw
    ; "draw" border around playing field
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

    ; position sprites
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

setMovePatternPtr
    #load16BitImmediate MOVE_PATTERNS, PLAYFIELD_PTR1 
    lda PLAY_FIELD.offsetEmpty
    asl
    asl
    asl
    clc
    adc PLAYFIELD_PTR1
    sta PLAYFIELD_PTR1
    ; handle carry
    lda PLAYFIELD_PTR1+1
    adc #0
    sta PLAYFIELD_PTR1+1
    rts


MOVE_PATTERNS ; UP, DOWN, LEFT, RIGHT
POS_0  .dstruct MoveOffsets_t, 4, NOT_POSSIBLE, 1, NOT_POSSIBLE, MOVE_UP | MOVE_LEFT
POS_1  .dstruct MoveOffsets_t, 5, NOT_POSSIBLE, 2, 0, MOVE_UP | MOVE_LEFT | MOVE_RIGHT
POS_2  .dstruct MoveOffsets_t, 6, NOT_POSSIBLE, 3, 1, MOVE_UP | MOVE_LEFT | MOVE_RIGHT
POS_3  .dstruct MoveOffsets_t, 7, NOT_POSSIBLE, NOT_POSSIBLE, 2, MOVE_UP | MOVE_RIGHT

POS_4  .dstruct MoveOffsets_t, 8, 0, 5, NOT_POSSIBLE, MOVE_UP | MOVE_DOWN | MOVE_LEFT
POS_5  .dstruct MoveOffsets_t, 9, 1, 6, 4, MOVE_ALL
POS_6  .dstruct MoveOffsets_t, 10,2, 7, 5, MOVE_ALL
POS_7  .dstruct MoveOffsets_t, 11,3, NOT_POSSIBLE, 6, MOVE_UP | MOVE_DOWN | MOVE_RIGHT

POS_8  .dstruct MoveOffsets_t, 12, 4, 9, NOT_POSSIBLE, MOVE_UP | MOVE_DOWN | MOVE_LEFT
POS_9  .dstruct MoveOffsets_t, 13, 5, 10, 8, MOVE_ALL
POS_10 .dstruct MoveOffsets_t, 14, 6, 11, 9, MOVE_ALL
POS_11 .dstruct MoveOffsets_t, 15, 7, NOT_POSSIBLE, 10, MOVE_UP | MOVE_DOWN | MOVE_RIGHT

POS_12 .dstruct MoveOffsets_t, NOT_POSSIBLE, 8, 13, NOT_POSSIBLE, MOVE_DOWN | MOVE_LEFT
POS_13 .dstruct MoveOffsets_t, NOT_POSSIBLE, 9, 14, 12, MOVE_DOWN | MOVE_LEFT | MOVE_RIGHT
POS_14 .dstruct MoveOffsets_t, NOT_POSSIBLE, 10, 15, 13, MOVE_DOWN | MOVE_LEFT | MOVE_RIGHT
POS_15 .dstruct MoveOffsets_t, NOT_POSSIBLE, 11, NOT_POSSIBLE, 14, MOVE_DOWN | MOVE_RIGHT

MSG_ALL_IN_ORDER .text "All is in order. Well done!"

makeMove
    jsr makeMoveInternal
    bcs _doneIllegal
    ;jsr draw
    jsr sprites.animate
    jsr isOrdered
    bcs _done
    #locate 24, 3
    #printString MSG_ALL_IN_ORDER, len(MSG_ALL_IN_ORDER)
_done
    rts
_doneIllegal
    jsr sid.beepIllegal
    jsr sid.beepOff
    rts

TRANS_RANDOM 
.byte %00000001 
.byte %00000010
.byte %00000100
.byte %00001000

RAND_COUNT .byte ?
RAND_COUNT_HIGH .byte ?


shuffle
    stz RAND_COUNT
    stz RAND_COUNT_HIGH
_randLoop
    jsr random.getNibble
    and #03
    tay
    ldx TRANS_RANDOM, y
    jsr makeMoveInternal
    inc RAND_COUNT
    lda RAND_COUNT
    bne _randLoop
    inc RAND_COUNT_HIGH
    lda RAND_COUNT_HIGH
    cmp #3
    bne _randLoop
    rts


shuffleTest
    stz RAND_COUNT
_randLoop
    jsr random.getNibble
    and #03
    tay
    ldx TRANS_RANDOM, y
    jsr makeMoveInternal
    inc RAND_COUNT
    lda RAND_COUNT
    cmp #5
    bne _randLoop
    rts


; x contains move selected by the user
makeMoveInternal
    jsr setMovePatternPtr
    txa
    ldy #MoveOffsets_t.moves
    and (PLAYFIELD_PTR1), y
    beq _doneIllegal
    stx sprites.ANIMATE_TASK.direction
    jsr bitFlagToOffset
    sty SCRATCH    
    lda (PLAYFIELD_PTR1), y                                                 ; determine offset which moves
    tay
    sty sprites.ANIMATE_TASK.playfieldOffset
    lda PLAY_FIELD.playField, y                                             ; load current value at move pos    
    sta sprites.ANIMATE_TASK.spriteId
    ldy PLAY_FIELD.offsetEmpty                                              ; load offset of current empty pos
    sty sprites.ANIMATE_TASK.emptyOffset
    sta PLAY_FIELD.playField, y                                             ; store value mfrom move pos

    ldy SCRATCH
    lda (PLAYFIELD_PTR1), y                                                 ; recreate offset that moves
    tay
    lda #0
    sta PLAY_FIELD.playfield, y                                             ; make this field empty
    sty PLAY_FIELD.offsetEmpty                                              ; offset in y is the empty offset

    ; calculate x and y coordinates of block to move
    lda sprites.ANIMATE_TASK.playfieldOffset
    jsr calcPlayFieldCoordinates
    stx sprites.ANIMATE_TASK.currentX
    sty sprites.ANIMATE_TASK.currentY

    ; calculate x and y coordinate of where to move block
    lda sprites.ANIMATE_TASK.emptyOffset
    jsr calcPlayFieldCoordinates    
    stx sprites.ANIMATE_TASK.targetX
    sty sprites.ANIMATE_TASK.targetY

    clc
    rts
_doneIllegal
    sec
    rts

.endnamespace