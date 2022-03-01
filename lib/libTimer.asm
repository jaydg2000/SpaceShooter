#importonce

.const maxTimers =      $F0
timer_max:              .fill maxTimers, $00
timer:                  .fill maxTimers, $00

.macro enable_timer(nTimer, nMax) {
    ldy #nTimer
    lda #nMax
    sta timer_max,y
    lda #$00
    sta timer,y
}

.macro timer_tick(nTimer) {
    ldx #nTimer
    lda timer,x
    cmp timer_max,x
    bcs end
    inc timer,x
end:    
}

.macro timer_check(nTimer) {
    ldx #$00
    ldy #nTimer
    lda timer,y
    cmp timer_max,y             // check carry flag BCS for timer has elapsed, 
                                // call timer_reset to restart timer
}

.macro timer_reset(nTimer) {
    ldy #nTimer
    lda #$00
    sta timer,y
}