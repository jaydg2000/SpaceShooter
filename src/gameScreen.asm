#import "gameMemory.asm"
#import "..\lib\libVIC.asm"
#import "..\lib\libMath.asm"

.const screen_data_1 = $2200
.const screen_data_2 = screen_data_1 + 256
.const screen_data_3 = screen_data_2 + 256
.const screen_data_4 = screen_data_3 + 256

.const color_data_1 = screen_data_1 + 1000
.const color_data_2 = color_data_1 + 256
.const color_data_3 = color_data_2 + 256
.const color_data_4 = color_data_3 + 256

.macro load_screen() {
    ldx #$00
!loop:
    // bank 1
    lda screen_data_1,x
    sta $0400,x
    // bank 2
    lda screen_data_2,x
    sta $0500,x
    // bank 2
    lda screen_data_3,x
    sta $0600,x    
    cpx #$ff
    beq final
    inx
    jmp !loop-    
final:                          // final bank of 232/$e7
    ldx #$e7
!loop:
    lda screen_data_4,x
    sta $0700,x    
    cpx #$00    
    beq end
    dex
    jmp !loop-
end:    
}

.macro load_screen_colors() {
    ldx #$00
!loop:
    // bank 1
    lda color_data_1,x
    sta color_ram,x
    // bank 2
    lda color_data_2,x
    sta color_ram+256,x
    // bank 2
    lda color_data_3,x
    sta color_ram+512,x    
    cpx #$ff
    beq final
    inx
    jmp !loop-    
final:                          // final bank of 232/$e7
//.break
    ldx #$e7
!loop:
    lda color_data_4,x
    sta color_ram+768,x    
    cpx #$00    
    beq end
    dex
    jmp !loop-
end:    
}

.macro twinkle_stars() {
        ldx #$FF
        // first bank of 256 bytes
loop:   lda $0400,x             
        cmp #$2E
        bne bank2
        color_star()
        cmp #$FF
        beq bank2
        sta $D800,x
        // second bank of 256 bytes
bank2:  lda $0500,x
        cmp #$2E
        bne bank3
        color_star()
        cmp #$FF
        beq bank3
        sta $D900,x
        // third bank of 256 bytes
bank3:  lda $0600,x
        cmp #$2E
        bne bank4
        color_star()
        cmp #$FF
        beq bank4
        sta $DA00,x        
        // fourth bank of 232 bytes
bank4:  cpx #$E7
        bcs next
        lda $0700,x
        cmp #$2E
        bne next
        color_star()
        cmp #$FF
        beq next
        sta $DB00,x
next:   dex
        beq end
        jmp loop
end:
}

.macro color_star() {
        jsr rand
        cmp #$05
        bcc white
        cmp #$0A
        bcc gray
        cmp #$0F
        bcc blue
        lda #$FF
        jmp end
blue:   lda #color_blue
        jmp end
gray:   lda #color_gray_2
        jmp end
white:  lda #color_white
end:
}