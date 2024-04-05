
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
    lda myEvent.key.ascii
    jsr testForFKey
    bcc eventLoop
_checkAscii
    lda myEvent.key.ascii
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

MSG_START_1 .text "F256 15 puzzle start state"

enterState
    lda GLOBAL_STATE.globalCol
    sta CURSOR_STATE.col
    jsr txtio.clear

    #locate 9, 35
    #printString MSG_START_1, len(MSG_START_1)
    rts

leaveState
    rts


ST_START_DATA .dstruct StartState_t

.endn