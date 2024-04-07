.include "txtrect.asm"

st_15puzzle .namespace

State15Puzzle_t .struct
    doAnimation .byte 0
.ends

ST_15_PUZZLE_DATA .dstruct State15Puzzle_t


MSG_GAME_1 .text "Press F1 to abort game and return to intro screen"
MSG_GAME_3 .text "Press F3 to toggle tile animation"
MSG_GAME_2 .text "Use      keys or       in port 1 to move tiles"
MSG_RESTORE_ORDER .text "Restore the original order of the tiles"

enterState
    lda GLOBAL_STATE.globalCol
    sta CURSOR_STATE.col
    jsr txtio.clear
    ; set black background color in graphics mode
    stz $D00D
    stz $D00E
    stz $D00F

    jsr txtio.newLine
    jsr playfield.init
    jsr playfield.shuffle
    jsr playfield.draw

    lda #15
    jsr sprites.callSetSpritePointer
    jsr sprites.on16

    lda #16
    jsr sprites.callSetSpritePointer
    jsr sprites.on16

    lda ST_15_PUZZLE_DATA.doAnimation
    sta playfield.PLAY_FIELD.doAnimation
    jsr playfield.animationIconChange

    #locate 18, 2
    #printString MSG_RESTORE_ORDER, len(MSG_RESTORE_ORDER)

    #locate 13, 49
    #printString MSG_GAME_1, len(MSG_GAME_1)
    #locate 20, 52
    #printString MSG_GAME_3, len(MSG_GAME_3)
    #locate 14, 55
    #printString MSG_GAME_2, len(MSG_GAME_2)

    rts

eventLoop
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl eventLoop
    ; Get the next event.
    jsr kernel.NextEvent
    bcs eventLoop
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _keyPress
    cmp #kernel.event.JOYSTICK
    bne _noKnownEvent
    jsr testJoyStick
_noKnownEvent
    bra eventLoop
_keyPress
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _checkAscii
    lda myEvent.key.raw
    jsr testForFKey
    bcc eventLoop
    bra _compare
_checkAscii
    lda myEvent.key.ascii
_compare
    cmp #KEY_F1
    bne _testF3
    #setstate S_START
    bra _endEvent
_testF3
    cmp #KEY_F3
    bne _testCursorUp
    lda playfield.PLAY_FIELD.doAnimation
    eor #1
    sta playfield.PLAY_FIELD.doAnimation
    jsr playfield.animationIconChange
    bra eventLoop
_testCursorUp
    cmp #16
    bne _testCursorDown
    ldx #MOVE_UP
    jsr performOperation
    bra eventLoop
_testCursorDown
    cmp #14
    bne _testCursorLeft
    ldx #MOVE_DOWN
    jsr performOperation
    bra eventLoop
_testCursorLeft
    cmp #2
    bne _testCursorRight
    ldx #MOVE_LEFT
    jsr performOperation
    jmp eventLoop
_testCursorRight
    cmp #6
    beq _shiftRight
    jmp eventLoop
_shiftRight
    ldx #MOVE_RIGHT
    jsr performOperation
    jmp eventLoop
_endEvent
    rts


testJoyStick
    lda myEvent.joystick.joy0
    cmp #1    
    bne _checkDown
    ldx #MOVE_UP
    jsr performOperation
    bra _done    
_checkDown
    cmp #2
    bne _checkLeft
    ldx #MOVE_DOWN
    jsr performOperation
    bra _done
_checkLeft
    cmp #4
    bne _checkRight
    ldx #MOVE_LEFT
    jsr performOperation
    bra _done
_checkRight
    cmp #8
    bne _done
    ldx #MOVE_RIGHT
    jsr performOperation
_done    
    rts


MSG_UP .text "up", $0d
MSG_DOWN .text "down", $0d
MSG_LEFT .text "left", $0d
MSG_RIGHT .text "right", $0d

; x-reg = MOVE_UP    => Shift Up
; x-reg = MOVE_DOWN  => Shift Down
; x-reg = MOVE_LEFT  => Shift Left
; x-reg = MOVE_RIGHT => Shift Right
performOperation
    cpx #MOVE_UP
    bne _checkDown    
    jsr playField.makeMove
    rts
_checkDown
    cpx #MOVE_DOWN
    bne _checkLeft
    jsr playField.makeMove
    rts
_checkLeft
    cpx #MOVE_LEFT
    bne _checkRight    
    jsr playField.makeMove
    rts
_checkRight
    cpx #MOVE_RIGHT
    bne _ignore    
    jsr playField.makeMove
    rts
_ignore
    rts


leaveState
    lda playfield.PLAY_FIELD.doAnimation
    sta ST_15_PUZZLE_DATA.doAnimation

    lda #15
    jsr sprites.callSetSpritePointer
    jsr sprites.off16

    lda #16
    jsr sprites.callSetSpritePointer
    jsr sprites.off16

    jsr sprites.deactivate
    rts

.endn