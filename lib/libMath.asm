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