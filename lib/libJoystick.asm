#importonce
#import "libDefines.asm"

// Port Masks
.label GameportUpMask       = %00000001
.label GameportDownMask     = %00000010
.label GameportLeftMask     = %00000100
.label GameportRightMask    = %00001000
.label GameportFireMask     = %00010000

.macro joystick_read(bPortMask)
{
    lda CIAPRA      // Load joystick 2 state to A
    and #bPortMask  // Mask out direction/fire required
} // Test with bne immediately after the call