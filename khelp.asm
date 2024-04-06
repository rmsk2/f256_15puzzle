; value of event buffer at program start (likely set by `superbasic`)
oldEvent .byte 0, 0
; the new event buffer
myEvent .dstruct kernel.event.event_t


; --------------------------------------------------
; This routine saves the current value of the pointer to the kernel event 
; buffer and sets that pointer to the address of myEvent. This in essence
; disconnects superbasic from the kernel event stream.
;--------------------------------------------------
initEvents
    #move16Bit kernel.args.events, oldEvent
    #load16BitImmediate myEvent, kernel.args.events
    rts


; --------------------------------------------------
; This routine restores the pointer to the kernel event buffer to the value
; encountered at program start. This reconnects superbasic to the kernel
; event stream.
;--------------------------------------------------
restoreEvents
    #move16Bit oldEvent, kernel.args.events
    rts


FKEYS .byte $81, $82, $83, $84, $85, $86, $87, $88

testForFKey
    phx
    ldx #0
_loop
    cmp FKEYS, x
    beq _isFKey
    inx
    cpx #8
    bne _loop
    plx
    clc
    rts
_isFKey
    plx
    sec
    rts


; waiting for a key press event from the kernel
waitForKey
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl waitForKey
    ; Get the next event.
    jsr kernel.NextEvent
    bcs waitForKey
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    bra waitForKey
_done
    lda myEvent.key.flags 
    and #myEvent.key.META
    bne waitForKey
    lda myEvent.key.ascii
    rts

; waiting for a key press event from the kernel
waitForKeyWithFKeys
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl waitForKey
    ; Get the next event.
    jsr kernel.NextEvent
    bcs waitForKey
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    bra waitForKey
_done
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _isAscii
    lda myEvent.key.raw                                      ; retrieve raw key code
    jsr testForFKey
    bcc waitForKey                                           ; a meta key but not an F-Key was pressed => we are not done
    rts                                                      ; it was an F-Key => return raw key code a ascii value
_isAscii
    lda myEvent.key.ascii
    rts


; Dummy callback which ends keyEventLoop and simpleKeyEventLoop
dummyCallBack
    clc
    rts


SIMPLE_FOCUS_VECTOR .word dummyCallBack


simpleCallback
    jmp (SIMPLE_FOCUS_VECTOR)


simpleKeyEventLoop
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl simpleKeyEventLoop
    ; Get the next event.
    jsr kernel.NextEvent
    bcs simpleKeyEventLoop
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _evalChar
    bra simpleKeyEventLoop
_evalChar
    lda myEvent.key.flags 
    and #myEvent.key.META
    beq _isAscii
    lda myEvent.key.raw                                      ; retrieve raw key code
    jsr testForFKey
    bcc simpleKeyEventLoop                                   ; a meta key but not an F-Key was pressed => we are not done
    bra _doProc                                              ; it was an F-Key 
_isAscii
    lda myEvent.key.ascii
_doProc
    jsr simpleCallback
    bcs simpleKeyEventLoop
    rts


; See chapter 17 of the system manual. Section 'Software reset'
sys64738
    lda #$DE
    sta $D6A2
    lda #$AD
    sta $D6A3
    lda #$80
    sta $D6A0
    lda #00
    sta $D6A0
    rts

TIMER_COOKIE_ANIMATION .byte 0
TIMER_COOKIE_GAME .byte 1
TIMER_COOKIE_DELAY .byte 2

setTimerHelp .macro type, interval, cookieSrc
    ; get current value of timer
    lda #\type | kernel.args.timer.QUERY
    sta kernel.args.timer.units
    jsr kernel.Clock.SetTimer
    ; carry should be clear here as previous jsr clears it, when no error occurred
    ; make a timer which fires interval units from now
    adc #\interval
    sta kernel.args.timer.absolute
    lda #\type
    sta kernel.args.timer.units
    lda \cookieSrc
    sta kernel.args.timer.cookie
    ; Create timer
    jsr kernel.Clock.SetTimer
.endmacro

setTimerAnimation 
    #setTimerHelp kernel.args.timer.FRAMES, 1, TIMER_COOKIE_ANIMATION
    rts

setTimerClockTick
    #setTimerHelp kernel.args.timer.SECONDS, 1, TIMER_COOKIE_GAME
    rts

RTC_BUFFER .dstruct kernel.time_t

kGetTimeStamp
    #load16BitImmediate RTC_BUFFER, kernel.args.buf
    lda #size(kernel.time_t)
    sta kernel.args.buflen
    jsr kernel.Clock.GetTime
    lda RTC_BUFFER.seconds
    sta RTCI2C.seconds
    lda RTC_BUFFER.minutes
    sta RTCI2C.minutes
    lda RTC_BUFFER.hours
    sta RTCI2C.hours
    rts

CONV_TEMP
.byte 0
; --------------------------------------------------
; This routine splits the value in accu its nibbles. The lower nibble 
; is returned in x and its upper nibble in the accu
; --------------------------------------------------
splitByte
    sta CONV_TEMP
    and #$0F
    tax
    lda CONV_TEMP
    and #$F0
    lsr
    lsr 
    lsr 
    lsr
    rts
