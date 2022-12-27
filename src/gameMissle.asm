#importonce
#import "..\lib\libDefines.asm"
#import "..\lib\libScreen.asm"
#import "..\lib\libTimer.asm"
#import "gameMemory.asm"

.const max_missiles = $01
.const missile_dir_up = $00
.const missile_dir_down = $01
.const missile_first_frame = $78
.const missle_total_frames = $04

missile_enable: .fill max_missiles, $00
missile_char_x: .fill max_missiles, $00
missile_char_y: .fill max_missiles, $00
missile_dir:    .fill max_missiles, $00
missile_char:   .fill max_missiles, missile_first_frame
missile_frames: .fill missle_total_frames, [missile_first_frame,missile_first_frame+i]

.macro create_missle(charX,charY,dir,offset) {
    ldx #$00
loop:                               // find open slot
    lda missile_enable,x
    beq create
    cpx #max_missiles
    beq setchar
    inx
    jmp loop
create:                             // slot found, create
    lda #$01
    sta missile_enable,x
    lda charX
    sta missile_char_x,x
    lda charY
    sta missile_char_y,x
    lda #dir
    sta missile_dir,x
setchar:
    ldy offset
    lda missile_frames,y
    sta missile_char,x
}

.macro move_missiles() {
    timer_check(timer_missile_move)
    bcc end
    timer_reset(timer_missile_move)
    jsr erase_missiles 
    ldx #$00
loop:
    lda missile_enable,x            // enabled?
    beq next
    lda missile_dir,x               // what direction is it moving?
    bne move_down
move_up:                            // move Y pos up
    dec missile_char_y,x
    jmp check                       
move_down:                          // move Y pos down
    inc missile_char_y,x
check:
    lda missile_char_y,x            // check for out of bounds
    cmp #$01
    beq remove
    cmp #$1A
    beq remove
    jmp end
remove:                             
    stx ZeroPage1
    remove_missile(ZeroPage1)    
next:                               // go to the next one
    inx
    cpx #max_missiles
    beq end
    jmp loop
end:
}

.macro remove_missile(index) {
    ldx #index
    lda #$00
    sta missile_enable,x    
}

render_missiles: {
    ldx #$00
loop:
    lda missile_enable,x
    beq next
    lda missile_char_x,x
    sta ZeroPage1
    lda missile_char_y,x
    sta ZeroPage2
    lda missile_char,x
    sta ZeroPage3
    set_char_screen(ZeroPage1,ZeroPage2,ZeroPage3)
next:
    inx
    cpx #max_missiles
    bcc loop
end:
    rts
}

erase_missiles: {
    ldx #$00
loop:
    lda missile_enable,x
    beq next
    lda missile_char_x,x
    sta ZeroPage1
    lda missile_char_y,x
    sta ZeroPage2
    lda #$20
    sta ZeroPage3
    set_char_screen(ZeroPage1,ZeroPage2,ZeroPage3)
next:
    inx
    cpx #max_missiles
    bcc loop
end:
    rts
}
