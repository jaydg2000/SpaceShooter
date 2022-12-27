*=$0801 "basic"
BasicUpstart(main)
*=$1000 "main"
#import "..\lib\libVIC.asm"
#import "..\lib\libSprite.asm"
#import "gamePlayer.asm"
#import "gameScreen.asm"

// F6 - run
// Shift F6 - debugger

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
    enable_timer(timer_missile_move, $05)
    sei

    // fire missle
    // get_player_char_x()
    // sta ZeroPage14
    // sty ZeroPage13
    // get_player_char_y()
    // sta ZeroPage15
    // create_missle(ZeroPage14,ZeroPage15,$00,ZeroPage13)
loop:
    vsync($FA)              // wait for frame to finish
    twinkle_stars()         // make the stars twinkle
    player_render()         // update player position    
    handle_player_input()   // move player with joystick movement
    move_missiles()    
    jsr render_missiles
    timer_tick(timer_missile_move)
    timer_tick(timer_player_fire)
    jmp loop
    rts

#import "gameContent.asm"
    
