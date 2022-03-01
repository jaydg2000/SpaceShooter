#importonce

// -------------- colors
.const color_black    = $00
.const color_white    = $01
.const color_red      = $02
.const color_cyan     = $03
.const color_purple   = $04
.const color_green    = $05
.const color_blue     = $06
.const color_yellow   = $07
.const color_orange   = $08
.const color_brown    = $09
.const color_red_2    = $0A
.const color_gray     = $0B
.const color_gray_2   = $0C
.const color_green_2  = $0D
.const color_blue_2   = $0E
.const color_gray_3   = $0F

.macro background_color(bColor) {
    lda #bColor
    sta $d021 
}

.macro border_color(bColor) {
    lda #bColor
    sta $d020
}

.macro clear_screen() {
    lda #$93
    jsr $FFD2     
}

.macro vsync(nScanline) {
wait_loop:
    lda $D012
    cmp #nScanline
    bne wait_loop
}

.macro character_memory(bBlock) {
    lda $D018
    and #$F0        // don't disturb the upper 4 bits
    ora #bBlock
    sta $D018
}