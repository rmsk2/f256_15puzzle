
st_start .namespace

StartState_t .struct 
    logoCol .byte 0
.ends

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
    beq _startGame
    cmp #KEY_F3
    beq _endGame
    bra _endEvent
_endGame
    #setState S_END    
    rts
_startGame
    #setstate S_GAME
_endEvent
    rts

MSG_START_1 .text "Press F1 to shuffle playfield and start game"
MSG_START_2 .text "Press F3 to reset to BASIC"
MSG_START_3 .text "15 puzzle. Written by Martin Grap (@mgr42) v1.1"
MSG_START_4 .text "during the April 2024 48 hour game jam on the Foenix Discord"
MSG_START_5 .text "See https://github.com/rmsk2/f256_15puzzle"

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

    #locate 14, 3
    #printString MSG_START_3, len(MSG_START_3)
    #locate 8, 6
    #printString MSG_START_4, len(MSG_START_4)

    #locate 15, 49
    #printString MSG_START_1, len(MSG_START_1)
    #locate 23, 52
    #printString MSG_START_2, len(MSG_START_2)
    #locate 16, 59
    #printString MSG_START_5, len(MSG_START_5)

    rts

leaveState
    jsr sprites.deactivate
    rts


ST_START_DATA .dstruct StartState_t

.endn