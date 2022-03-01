#importonce
#import "libDefines.asm"

wScreenRAMRowStart: // SCREENRAM + 40*0, 40*1, 40*2, 40*3, 40*4 ... 40*24
    .word SCREENRAM,     SCREENRAM+40,  SCREENRAM+80,  SCREENRAM+120, SCREENRAM+160
    .word SCREENRAM+200, SCREENRAM+240, SCREENRAM+280, SCREENRAM+320, SCREENRAM+360
    .word SCREENRAM+400, SCREENRAM+440, SCREENRAM+480, SCREENRAM+520, SCREENRAM+560
    .word SCREENRAM+600, SCREENRAM+640, SCREENRAM+680, SCREENRAM+720, SCREENRAM+760
    .word SCREENRAM+800, SCREENRAM+840, SCREENRAM+880, SCREENRAM+920, SCREENRAM+960

wColorRAMRowStart: // COLORRAM + 40*0, 40*1, 40*2, 40*3, 40*4 ... 40*24
    .word COLORRAM,     COLORRAM+40,  COLORRAM+80,  COLORRAM+120, COLORRAM+160
    .word COLORRAM+200, COLORRAM+240, COLORRAM+280, COLORRAM+320, COLORRAM+360
    .word COLORRAM+400, COLORRAM+440, COLORRAM+480, COLORRAM+520, COLORRAM+560
    .word COLORRAM+600, COLORRAM+640, COLORRAM+680, COLORRAM+720, COLORRAM+760
    .word COLORRAM+800, COLORRAM+840, COLORRAM+880, COLORRAM+920, COLORRAM+960

.macro set_char_screen(bXPos, bYPos, bChar) {
    lda bXPos
    sta ZeroPage1
    lda bYPos
    sta ZeroPage2
    lda bChar
    sta ZeroPage3
    jsr libScreen_SetCharacter
}

libScreen_SetCharacter: {
    lda ZeroPage2
    asl                             // multiply by 2 as RAM addr stored in words
    tay
    lda wScreenRAMRowStart,y        // low byte of screen RAM address
    sta ZeroPage9
    lda wScreenRAMRowStart+1,y      // high byte of screen RAM address
    sta ZeroPage10
    ldy ZeroPage1                   // x pos
    lda ZeroPage3                   // the character to display
    sta (ZeroPage9),y               // store char at the screen RAM addr
}