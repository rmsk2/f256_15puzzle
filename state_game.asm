.include "txtrect.asm"

st_15puzzle .namespace

State15Puzzle_t .struct
    tsStart .dstruct TimeStamp_t, 0, 0, 0
.ends

ST_15_PUZZLE_DATA .dstruct State15Puzzle_t


MSG_GAME_1 .text "Press F1 to abort game and return to intro screen"
MSG_GAME_2 .text "Use cursor keys or joystick in port 1 to move tiles"

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

    #locate 13, 49
    #printString MSG_GAME_1, len(MSG_GAME_1)
    #locate 12, 52
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
    cmp #kernel.event.timer.EXPIRED
    beq _timerEvent
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
    bne _testCursorUp
    #setstate S_START
    bra _endEvent
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
_timerEvent
    lda myEvent.timer.cookie
    cmp TIMER_COOKIE_GAME
    beq _cookieMatches
    jmp eventLoop
_cookieMatches
    ;
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
    jsr sprites.deactivate
    rts

.endn