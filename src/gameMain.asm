*=$0801 "basic"
BasicUpstart(main)
*=$1000 "main"
#import "..\lib\libVIC.asm"
#import "..\lib\libSprite.asm"
#import "gamePlayer.asm"
#import "gameScreen.asm"

main:    
    // background
    background_color(color_black)
    border_color(color_black)

    // character memory
    character_memory($0E)

    // sprites
    sprite_multicolor(LIGHT_RED,color_cyan)
    player_init()
    load_screen()
    load_screen_colors()

    sei
loop:
    vsync($FF)              // wait for frame to finish
    twinkle_stars()         // make the stars twinkle
    player_render()         // update player position    
    handle_player_input()   // move player with joystick movement
    jsr render_missiles
    jmp loop
    rts

#import "gameContent.asm"
    
