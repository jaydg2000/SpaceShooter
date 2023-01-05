#import "..\lib\libSprite.asm"
#import "..\lib\libTimer.asm"
#import "..\lib\libJoystick.asm"
#import "gameMemory.asm"
#import "gameMissle.asm"

// Player sprite attributes
player_x_hi:    .byte $00 //$00
player_x_lo:    .byte $ff //$af
player_y:       .byte $cd
player_firing:  .byte $00 // 0=no, !0=yes
firing_master:  .byte $00 // high order byte for firing timer

.const player_MSB_mask = %00000001
.const player_speed = $03

.macro player_init() {
    sprite_enable(sprite_number_player)
    sprite_data(sprite_number_player, $80)
    sprite_enable_multicolor(sprite_number_player)
    sprite_color(sprite_number_player, LIGHT_GRAY) 
    sprite_animation_count(sprite_number_player, 1)   // count is 0 based, 1 = 2 frames.

    enable_timer(timer_animate_player, $03)
    enable_timer(timer_player_fire, $10)
}

.macro player_render() {
    sprite_position(sprite_number_player, player_x_lo, player_x_hi, player_y)
    timer_tick(timer_animate_player)
    timer_check(timer_animate_player)
    bcc check_can_fire
    sprite_animate(sprite_number_player)
    timer_reset(timer_animate_player)
check_can_fire:
    timer_check(timer_player_fire)
    bcc end
    timer_reset(timer_player_fire)
    lda #$00
    sta player_firing
    timer_reset(timer_player_fire)
end:
}

.macro player_move_right(nPixels) {
    clc
    lda player_x_lo
    adc #nPixels
    sta player_x_lo
    tax                     // keep the low byte in X for bounds checking
    lda player_x_hi
    adc #$00
    sta player_x_hi    
    jsr bound_player
}

.macro player_move_left(nPixels) {
    sec
    lda player_x_lo
    sbc #nPixels
    sta player_x_lo    
    lda player_x_hi
    sbc #$00
    sta player_x_hi
    ldx player_x_lo    
    jsr bound_player
}

bound_player: {
    // too low?
    lda player_x_hi
    bne testforhi
    lda player_x_lo
    cmp #$11
    bcs end
    lda #$11
    sta player_x_lo
    jmp end
testforhi:
    lda player_x_lo
    cmp #$47
    bcc end
    lda #$47
    sta player_x_lo
end:
    rts
}

.macro handle_player_input() {
check_left:    
    joystick_read(GameportLeftMask)
    bne check_right
    player_move_left(player_speed)
    jmp end
check_right:
    joystick_read(GameportRightMask)
    bne check_fire
    player_move_right(player_speed)
check_fire:
    joystick_read(GameportFireMask)
    beq can_fire
    jmp end
can_fire:
    lda player_firing
    cmp #$00
    bne end
    lda #$01
    sta player_firing 
    timer_reset(timer_player_fire)
    // fire missle
    get_player_char_x()
    sta ZeroPage14
    sty ZeroPage13
    get_player_char_y()
    sta ZeroPage15    
    create_missle(ZeroPage14,ZeroPage15,$00,ZeroPage13)
end:    
}

.macro get_player_char_x() {    
    sec                 // subtract 24-12 (offset half width of sprite)
    lda player_x_lo
    sbc #$0C
    sta ZeroPage1
    sta ZeroPage3       // saving for calculating the offset    
    lda player_x_hi
    sbc #$00
    sta ZeroPage2
divide:
    lsr ZeroPage2       // divide by 8
    ror ZeroPage1
    lsr ZeroPage2
    ror ZeroPage1
    lsr ZeroPage2
    ror ZeroPage1
    //bcc offset
    //inc ZeroPage1
offset:
    lda ZeroPage1       // multiply char X by 8
    sta ZeroPage4
    asl ZeroPage4
    rol ZeroPage4
    rol ZeroPage4
    lda ZeroPage3       // subtract char X * 8 from adjusted pixel X
    sec
    sbc ZeroPage4
    tay
done:
    lda ZeroPage1       // A will have X char pos
                        // y will have offset
}

.macro get_player_char_y() {  
    sec                 // subtract 50
    lda player_y
    sbc #$32
    sta ZeroPage1
    
    lsr ZeroPage1       // divide by 8
    lsr ZeroPage1
    lsr ZeroPage1    
    lda ZeroPage1       // A will have Y char pos
}