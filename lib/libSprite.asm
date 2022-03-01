#importonce

spriteAnimationFrameCount: .fill 8, $00
spriteAnimationCurrentFrame: .fill 8, $00
spriteAnimationCurrentDataPtr: .fill 8, $00
spriteDataPtr: .fill 8, $00
spriteNumberMask:  .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

.label SP0ENABLE = $d015
.label SP0DATA = $07f8
.label SP0COLOR = $d027

.macro sprite_enable(nSpriteNumber) {
    ldy #nSpriteNumber
    lda SP0ENABLE
    ora spriteNumberMask,y
    sta SP0ENABLE
}

.macro sprite_disable(nSpriteNumber) {
    ldy #nSpriteNumber
    lda SP0ENABLE
    eor spriteNumberMask,y
    sta SP0ENABLE
}

.macro sprite_color(nSpriteNumber, nColor) {
    ldy #nSpriteNumber
    lda #nColor
    sta SP0COLOR,y
}

.macro sprite_enable_multicolor(nSpriteNumber) {
    ldy #nSpriteNumber
    lda $d01c
    ora spriteNumberMask,y
    sta $d01c
}

.macro sprite_multicolor(nColor0, nColor1) {
    lda #nColor0
    sta $d025
    lda #nColor1
    sta $d026
}

.macro sprite_data(nSpriteNumber, bBlock) {
    ldy #nSpriteNumber
    lda #bBlock
    sta spriteDataPtr,y
    sta SP0DATA,y
}

.macro sprite_position(nSpriteNumber, bLoByteX, bHiByteX, bY) {    
    ldy #nSpriteNumber
    lda bHiByteX                // check the hi byte of the X position
    bne setXMSB                 // if not zero, set the XMSB bit    
    lda spriteNumberMask,y      // otherwise load the XMSB bits 
    eor $d010                   // get the inverse of the mask
    and $d010                   // and with the XMSB bits to turn it off
    sta $d010                   // store back to XMSB register
    jmp setX                    // go set the X position of the sprite

setXMSB:
    lda $d010                   // load XMSB register
    ora spriteNumberMask,y      // turn on specific sprite XMSB bit
    sta $d010                   // store back to XMSB register
setX: 
    lda bLoByteX                // load A with sprite X low byte
    sta $d000,y                 // A should be preloaded with true X
setY:    
    lda bY
    sta $d001
}

.macro sprite_animation_count(nSpriteNumber, nFrames) {
    ldy #nSpriteNumber
    lda #nFrames
    sta spriteAnimationFrameCount,y
    lda #$00
    sta spriteAnimationCurrentFrame,y
    lda spriteDataPtr,y
    sta spriteAnimationCurrentDataPtr,y
}

.macro sprite_animate(nSpriteNumber) {
    ldx #nSpriteNumber
    lda spriteAnimationCurrentFrame,x
    cmp spriteAnimationFrameCount,x
    bcc next
    lda spriteDataPtr,x
    sta spriteAnimationCurrentDataPtr,x
    lda #$00
    sta spriteAnimationCurrentFrame,x
    jmp end
next:
    inc spriteAnimationCurrentFrame,x    
    inc spriteAnimationCurrentDataPtr,x
end:    
    lda spriteAnimationCurrentDataPtr,x
    sta SP0DATA,x
}

.macro sprite_set_frame(nSpriteNumber, nFrame) {
    ldy #nSpriteNumber
    lda #nFrame
    sta spriteAnimationCurrentFrame,y    
}