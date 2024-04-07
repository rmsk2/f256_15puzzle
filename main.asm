.include "api.asm"
.cpu "w65c02"
* = $2500

jmp main

KEY_F1 = 129
KEY_F3 = 131
GLOBAL_COL = $10

HEX_CHARS
.text "0123456789ABCDEF"

.include "zeropage.asm"
.include "clut.asm"
.include "arith16.asm"
.include "khelp.asm"
.include "txtio.asm"
.include "rtc.asm"
.include "beep.asm"
.include "random.asm"
.include "spritecontrol.asm"
.include "playfield.asm"
.include "states.asm"
.include "state_start.asm"
.include "state_game.asm"

S_START .dstruct GameState_t, st_start.eventLoop, st_start.enterState, st_start.leaveState, st_start.ST_START_DATA
S_GAME  .dstruct GameState_t, st_15puzzle.eventLoop, st_15puzzle.enterState, st_15puzzle.leaveState, st_15puzzle.ST_15_PUZZLE_DATA 
S_END   .dstruct EndState_t

GlobalState_t .struct 
    globalCol .byte GLOBAL_COL
.ends

GLOBAL_STATE .dstruct GlobalState_t

main
    ; setup MMU, this seems to be neccessary when running as a PGX
    lda #%10110011                         ; set active and edit LUT to three and allow editing
    sta 0
    lda #%00000000                         ; enable io pages and set active page to 0
    sta 1

    ; map BASIC ROM out and RAM in
    lda #4
    sta 8+4
    lda #5
    sta 8+5

    jsr clut.init

    lda #GLOBAL_COL
    sta GLOBAL_STATE.globalCol
    jsr txtio.init
    jsr random.init
    jsr sid.init
    ; create a new event queue and save pointer to event queue of superbasic
    jsr initEvents

    #setStartState S_START
mainLoop
    jsr isStateEnd    
    beq _done
    jsr stateEventLoop
    bra mainLoop
_done
    jsr sys64738

    rts
