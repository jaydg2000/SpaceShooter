#importonce
#import "..\lib\libDefines.asm"
#import "..\lib\libScreen.asm"

.const max_missiles = $08
.const missile_dir_up = $00
.const missile_dir_down = $01

missile_enable: .fill max_missiles, $00
missile_char_x: .fill max_missiles, $00
missile_char_y: .fill max_missiles, $00
missile_dir:    .fill max_missiles, $00
missile_char:   .fill max_missiles, $78

.macro create_missle(charX,charY,dir) {
    ldx #$00
loop:                               // find open slot
    lda missile_enable,x
    beq create
    cpx #max_missiles
    beq end
    inx
    jmp loop
create:                             // slot found, create
    lda #charX
    sta missile_char_x,x
    lda #charY
    sta missile_char_y,x
    lda #dir
    sta missile_dir,x
end:
}

.macro move_missiles() {
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
    lda missile_char_y,y            // check for out of bounds
    beq remove
    cmp #$1A
    beq remove
    jmp end
remove:                             
    stx ZeroPage1
    remove_missile(ZeroPage1)    
next:                               // go to the next one
    inx
    cmp #max_missiles
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
