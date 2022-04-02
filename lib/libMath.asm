#importonce
#import "libDefines.asm"

// random seed
seedhi:  .byte $FF
seedlo:  .byte $FF

rand: {
    lda seedhi
    lsr
    rol seedlo            
    bcc noeor             
    eor #$B4              
noeor:
    sta seedhi            
    eor seedlo 
    rts
}

.macro libMath_8bitTObcd(bIn, wOut)
{
    ldy bIn
    sty ZeroPage13  // Store in a temporary variable
    sed 		    // Switch to decimal mode
	lda #0          // Ensure the result is clear
	sta wOut
	sta wOut+1
	ldx #8		    // The number of source bits
cnvBit:
    asl ZeroPage13	// Shift out one bit
	lda wOut        // And add into result
	adc wOut
	sta wOut
	lda wOut+1	    // propagating any carry
	adc wOut+1
	sta wOut+1
	dex		        // And repeat for next bit
	bne cnvBit
	cld		        // Back to binary
}