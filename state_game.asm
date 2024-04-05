.include "txtrect.asm"

st_15puzzle .namespace

State15Puzzle_t .struct
    tsStart .dstruct TimeStamp_t, 0, 0, 0
.ends

ST_15_PUZZLE_DATA .dstruct State15Puzzle_t


MSG_GAME_START_1 .text "15 puzzle game state", $0d


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
    jsr playfield.draw
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
    lda myEvent.key.ascii
    jsr testForFKey
    bcc eventLoop
_checkAscii
    lda myEvent.key.ascii
    cmp #KEY_F1
    bne _testCursorUp
    #setstate S_START
    bra _endEvent
_testCursorUp
    cmp #16
    bne _testCursorDown
    ldx #0
    jsr performOperation
    bra eventLoop
_testCursorDown
    cmp #14
    bne _testCursorLeft
    ldx #2
    jsr performOperation
    bra eventLoop
_testCursorLeft
    cmp #2
    bne _testCursorRight
    ldx #4
    jsr performOperation
    jmp eventLoop
_testCursorRight
    cmp #6
    beq _shiftRight
    jmp eventLoop
_shiftRight
    ldx #6
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
    ldx #0
    jsr performOperation
    bra _done    
_checkDown
    cmp #2
    bne _checkLeft
    ldx #2
    jsr performOperation
    bra _done
_checkLeft
    cmp #4
    bne _checkRight
    ldx #4
    jsr performOperation
    bra _done
_checkRight
    cmp #8
    bne _done
    ldx #6
    jsr performOperation
_done    
    rts


MSG_UP .text "up", $0d
MSG_DOWN .text "down", $0d
MSG_LEFT .text "left", $0d
MSG_RIGHT .text "right", $0d

; x-reg = 0 => Shift Up
; x-reg = 2 => Shift Down
; x-reg = 4 => Shift Left
; x-reg = 6 => Shift Right
performOperation
    cpx #0
    bne _checkDown
    #printString MSG_UP, len(MSG_UP)
    rts
_checkDown
    cpx #2
    bne _checkLeft
    #printString MSG_DOWN, len(MSG_DOWN)
    rts
_checkLeft
    cpx #4
    bne _checkRight
    #printString MSG_LEFT, len(MSG_LEFT)
    rts
_checkRight
    cpx #6
    bne _ignore
    #printString MSG_RIGHT, len(MSG_RIGHT)
    rts
_ignore
    rts


leaveState
    jsr sprites.deactivate
    rts

.endn