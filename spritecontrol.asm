

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

SPR_CURSOR = 15 * 1024
SPR_JOYSTICK = 15 * 1024 + 256
OFF_ICON = SPR_JOYSTICK + 256

CURSOR_POS_X = 120-16
CURSOR_POS_Y = 246

JOYSTICK_POS_X = 174-16
JOYSTICK_POS_Y = 247

OFF_POS_X = 222
OFF_POS_Y = 238

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
    ; turn off all sprites
    #load16BitImmediate $D900, SPRITE_PTR1
    ldx #0
_turnOfLoop
    lda #0
    sta (SPRITE_PTR1)
    #add16BitImmediate 8, SPRITE_PTR1
    inx
    cpx #64
    bne _turnOfLoop

    ; set bitmap data for all sprites representing tiles
    ldy #0                                              ; sprite block  0..14
_sprLoop
    tya
    jsr callSetSpritePointer
    tya
    jsr setBitmapAddr
    iny
    cpy #15
    bne _sprLoop

    ; initialize cursor keys icon
    lda #15
    jsr callSetSpritePointer
    ; set data
    ldy #SpriteBlock_t.addr
    lda #<SPR_CURSOR
    sta (SPRITE_PTR1), y
    iny
    lda #>SPR_CURSOR
    sta (SPRITE_PTR1), y
    iny
    lda #2
    sta (SPRITE_PTR1), y    

    ; set xpos
    ldy #SpriteBlock_t.xpos
    lda #<CURSOR_POS_X
    sta (SPRITE_PTR1), y
    iny
    lda #>CURSOR_POS_X
    sta (SPRITE_PTR1), y

    ; set ypos
    ldy #SpriteBlock_t.ypos
    lda #<CURSOR_POS_Y
    sta (SPRITE_PTR1), y
    iny
    lda #>CURSOR_POS_Y
    sta (SPRITE_PTR1), y

    ; intialize joystick icon
    lda #16
    jsr callSetSpritePointer
    ldy #SpriteBlock_t.addr
    ; set data
    lda #<SPR_JOYSTICK
    sta (SPRITE_PTR1), y
    iny
    lda #>SPR_JOYSTICK
    sta (SPRITE_PTR1), y
    iny
    lda #2
    sta (SPRITE_PTR1), y

    ; set xpos
    ldy #SpriteBlock_t.xpos
    lda #<JOYSTICK_POS_X
    sta (SPRITE_PTR1), y
    iny
    lda #>JOYSTICK_POS_X
    sta (SPRITE_PTR1), y

    ; set ypos
    ldy #SpriteBlock_t.ypos
    lda #<JOYSTICK_POS_Y
    sta (SPRITE_PTR1), y
    iny
    lda #>JOYSTICK_POS_Y
    sta (SPRITE_PTR1), y

    ; intialize OFF icon
    lda #17
    jsr callSetSpritePointer
    ldy #SpriteBlock_t.addr
    ; set data
    lda #<OFF_ICON
    sta (SPRITE_PTR1), y
    iny
    lda #>OFF_ICON
    sta (SPRITE_PTR1), y
    iny
    lda #2
    sta (SPRITE_PTR1), y

    ; set xpos
    ldy #SpriteBlock_t.xpos
    lda #<OFF_POS_X
    sta (SPRITE_PTR1), y
    iny
    lda #>OFF_POS_X
    sta (SPRITE_PTR1), y

    ; set ypos
    ldy #SpriteBlock_t.ypos
    lda #<OFF_POS_Y
    sta (SPRITE_PTR1), y
    iny
    lda #>OFF_POS_Y
    sta (SPRITE_PTR1), y



    ; Activate sprite layer
    jsr activate
    rts

offIconShow
    lda #17
    jsr callSetSpritePointer
    jsr on8
    rts

offIconInvisible
    lda #17
    jsr callSetSpritePointer
    jsr off8
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

onWithSize .macro size
    lda #\size | SPR_LAYER_0 | SPR_LUT_0 | SPR_ENABLE
    sta (SPRITE_PTR1)
.endmacro


offWithSize .macro size
    lda #\size | SPR_LAYER_0 | SPR_LUT_0 
    sta (SPRITE_PTR1)
.endmacro


; SPRITE_PTR1 has to be set to correct block
on
    #onWithSize SPR_SIZE_32
    rts

; SPRITE_PTR1 has to be set to correct block
off
    #offWithSize SPR_SIZE_32
    rts    

; SPRITE_PTR1 has to be set to correct block
on16
    #onWithSize SPR_SIZE_16
    rts

; SPRITE_PTR1 has to be set to correct block
off16
    #offWithSize SPR_SIZE_16
    rts    

; SPRITE_PTR1 has to be set to correct block
on8
    #onWithSize SPR_SIZE_8
    rts

; SPRITE_PTR1 has to be set to correct block
off8
    #offWithSize SPR_SIZE_8
    rts    


; lower 16 bits of addresses for the sprite data
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
; accu contains the the number of the 1K address block where sprite data lives
setBitmapAddr    
    phx
    phy    
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


COORD_Y .byte ?
; SPRITE_PTR1 has to be set to correct block
; x and y have to contain the coordinates on the playing field
setPosition
    phx
    phy        
    sty COORD_Y
    ; set xpos
    txa
    asl
    tax
    lda XPOSITIONS, x
    ldy #SpriteBlock_t.xpos
    sta (SPRITE_PTR1), y
    inx
    iny
    lda XPOSITIONS, x
    sta (SPRITE_PTR1), y
    ; set ypos
    lda COORD_Y
    asl
    tax
    ldy #SpriteBlock_t.ypos   
    lda YPOSITIONS, x
    sta (SPRITE_PTR1), y
    inx
    iny
    lda YPOSITIONS, x
    sta (SPRITE_PTR1), y
    ply
    plx
    rts


Animate_t .struct
    spriteId        .word ?
    direction       .byte ?
    playfieldOffset .byte ?
    emptyOffset     .byte ?
    currentX        .byte ?
    currentY        .byte ?
    targetX         .byte ?
    targetY         .byte ?
.endstruct

ANIMATE_TASK .dstruct Animate_t
ANIM_HELPER_START .dstruct SpriteBlock_t
ANIM_HELPER_END   .dstruct SpriteBlock_t

moveSprite
    lda ANIMATE_TASK.spriteId
    dea
    jsr callSetSpritePointer

    ; set X position
    ldy #SpriteBlock_t.xpos
    lda ANIM_HELPER_START.xpos    
    sta (SPRITE_PTR1), y
    iny
    lda ANIM_HELPER_START.xpos+1
    sta (SPRITE_PTR1), y

    ; set Y position
    ldy #SpriteBlock_t.ypos
    lda ANIM_HELPER_START.ypos
    sta (SPRITE_PTR1), y
    iny
    lda ANIM_HELPER_START.ypos+1
    sta (SPRITE_PTR1), y

    rts


X_DONE .byte ?
Y_DONE .byte ?

animate
    stz X_DONE
    stz Y_DONE
    #load16BitImmediate ANIM_HELPER_START, SPRITE_PTR1    
    ldx ANIMATE_TASK.currentX
    ldy ANIMATE_TASK.currentY
    jsr setPosition

    #load16BitImmediate ANIM_HELPER_END, SPRITE_PTR1    
    ldx ANIMATE_TASK.targetX
    ldy ANIMATE_TASK.targetY
    jsr setPosition
    jsr setTimerAnimation 
_eventLoop
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl _eventLoop
    ; Get the next event.
    jsr kernel.NextEvent
    bcs _eventLoop
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.timer.EXPIRED
    beq _timerEvent
    bra _eventLoop
_timerEvent
    lda myEvent.timer.cookie
    cmp TIMER_COOKIE_ANIMATION
    beq _cookieMatches
    jmp _eventLoop
_cookieMatches
    jsr performAnimationStep
    bcc _done
    jsr setTimerAnimation
    bra _eventLoop
_done
    rts


performAnimationStep
    #cmp16Bit ANIM_HELPER_START.xpos, ANIM_HELPER_END.xpos
    beq _xDone
    lda ANIMATE_TASK.direction
    and #MOVE_LEFT
    bne _decXPos
    #inc16Bit ANIM_HELPER_START.xpos
    bra _moveX
_decXPos
    #dec16Bit ANIM_HELPER_START.xpos    
_moveX
    jsr moveSprite
    bra _checkY
_xDone
    inc X_DONE
_checkY
    #cmp16Bit ANIM_HELPER_START.ypos, ANIM_HELPER_END.ypos
    beq _yDone
    lda ANIMATE_TASK.direction
    and #MOVE_UP
    bne _decYPos
    #inc16Bit ANIM_HELPER_START.ypos
    bra _moveY
_decYPos
    #dec16Bit ANIM_HELPER_START.ypos        
_moveY
    jsr moveSprite
    bra _testDone
_yDone
    inc Y_DONE
_testDone
    lda X_DONE
    and Y_DONE
    bne _animDone
    sec
    rts
_animDone
    clc
    rts

.endnamespace