; oooooleg@gmail.com Gubanov Oleg
; dmitry.zyr@gmail.com Zyryanov Dmitry


.includepath "/usr/share/avra/"
;mode state initial
.device ATtiny45

.equ PINB   = 0x16
.equ DDRB   = 0x17 ; init ports
.equ PORTB  = 0x18
.equ PB0    = 0x00
.equ PB1    = 0x01
.equ PB2    = 0x02
.equ PB3    = 0x03

.def pause_read_button_counter = r16
.def pause_read_button_counter2 = r17
.def button = r18
.def mode = r19
.def state = r20
.def state_counter = r21
.def state_counter2 = r22
.def state_counter3 = r23
.def blink_counter = r25
.def blink_counter2 = r26
.def blink_counter3 = r28
.def blink_state = r27
.def temp = r31
.def temp2 = r30

ldi pause_read_button_counter, 0
ldi pause_read_button_counter2, 0
ldi mode, 0
rcall init

; port B0 - input (button)
; ports B1,B2,B3 - output
sbi DDRB, PB1
sbi DDRB, PB2
sbi DDRB, PB3

; set ports on
sbi PORTB, PB0
;sbi PORTB, PB1
;sbi PORTB, PB2
;sbi PORTB, PB3


prog:
    cpi pause_read_button_counter, 0x00 ; compair with 0
    brne dont_read
    in button, PINB
    andi button, 0x01 ; check only 1 input bit from PB0
    cpi button, 0x00 ; look at button signal
    breq after_read ; if button not pushed --> go ahead
    ;if button pushed
    rcall change_mode
    ; set pause counter (now its 0)
dont_read:
    dec pause_read_button_counter 
    
after_read:
    mov temp, mode
    andi temp, 0x01 ; get mode % 2
    
    cpi temp, 0x00 ; check mode (on/off)
    brne mode_on
    breq mode_off

mode_off: ; blinking yellow
    inc blink_counter
    cpi blink_counter, 0x00
    brne set_light_yellow
    inc blink_counter2
    cpi blink_counter2, 0x00
    brne set_light_yellow
    inc blink_counter3
    cpi blink_counter3, 0x01
    brne set_light_yellow
    ldi blink_counter2, 0
    ldi blink_counter, 0
    ldi blink_counter3, 0
    inc blink_state ; if need to change blink state
            
    set_light_yellow:
        andi blink_state, 0x01 ; look at last bit
        ldi temp2, 0b00000011
        add blink_state, temp2 ; 
        ldi temp, 0b00000100
        and temp, blink_state
        out PORTB, temp ; switch yellow on/off
    
    rjmp prog

mode_on: ; red -> red,yellow -> green -> green' -> red
    mov temp, state
    andi temp, 0x03 ; state % 4
    
    cpi temp, 0x00 
    breq state_red
    cpi temp, 0x01
    breq state_red_yellow
    cpi temp, 0x02 
    breq state_green
    cpi temp, 0x03 
    breq state_green_blinking
    
; red
state_red: 
    inc state_counter
    cpi state_counter, 0x00
    brne light_red ; if red
    inc state_counter2
    cpi state_counter2, 0x00
    brne light_red ; if red 
    inc state_counter3
    cpi state_counter3, 0x02
    brne light_red ; if red 
    ;if need to change state
    inc state
    ldi state_counter3, 0
    rjmp state_red_yellow

    light_red:
            ldi temp, 0b00000010 ; red
            out PORTB, temp ; switch red on

    rjmp prog ; go in begin

; red + yellow
state_red_yellow:
    inc state_counter
    cpi state_counter, 0x00
    brne light_red_yellow ; 
    inc state_counter2
    cpi state_counter2, 0x00
    brne light_red_yellow ; 
    inc state_counter3
    cpi state_counter3, 0x02
    brne light_red_yellow ; 
    ;if need to change state
    inc state
    ldi state_counter3, 0
    rjmp state_green

    light_red_yellow:
            ldi temp, 0b00000110
            out PORTB, temp ; switch red + yellow on

    rjmp prog ; go in begin
    
; green
state_green:
    inc state_counter
    cpi state_counter, 0x00
    brne light_green ; 
    inc state_counter2
    cpi state_counter2, 0x00
    brne light_green ;
    inc state_counter3
    cpi state_counter3, 0x02
    brne light_green ;
    ;if need to change state
    inc state
    ldi state_counter3, 0
    ldi blink_counter, 0x00
    ldi blink_counter2, 0
    ldi blink_counter3, 0
    ldi blink_state, 0x00
    rjmp state_green_blinking

    light_green:
            ldi temp, 0b00001000
            out PORTB, temp ; switch green on

    rjmp prog ; go in begin


; blinking green
state_green_blinking:
    inc state_counter
    cpi state_counter, 0x00
    brne light_green_blinking ; 
    inc state_counter2
    cpi state_counter2, 0x00
    brne light_green_blinking ; 
    inc state_counter3
    cpi state_counter3, 0x02
    brne light_green_blinking ; 
    ;if need to change state
    inc state
    ldi state_counter3, 0
    rjmp state_red

    light_green_blinking:
            inc blink_counter
            cpi blink_counter, 0x80
            brne set_light
            inc blink_counter2
            cpi blink_counter2, 0x00
            brne set_light
            inc blink_counter3
            cpi blink_counter3, 0x02
            brne set_light
            ldi blink_counter2, 0
            inc blink_state ; if need to change blink state
            
        set_light:
            andi blink_state, 0x01 ; look at last bit
            ldi temp2, 0b00000111
            add blink_state, temp2 ; 
            ldi temp, 0b00001000
            and temp, blink_state
            out PORTB, temp ; switch green on/off

    rjmp prog ; go in begin
    


change_mode:
    inc mode
    rjmp init
    ret


init:
    ldi state, 0
    ldi state_counter, 0
    ldi state_counter2, 0
    ldi state_counter3, 0
    ldi blink_counter, 0
    ldi blink_counter2, 0
    ldi blink_counter3, 0
    ldi blink_state, 1
    ret
