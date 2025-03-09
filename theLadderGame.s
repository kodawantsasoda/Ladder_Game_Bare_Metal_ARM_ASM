//THE LADDER GAME - Dakota Rivera - Assembly Language - Final Project
/////////////////////////////////////////////////////////////////////
.align 4
.data
title: .asciz "WELCOME TO THE LADDER GAME\n"
design: .asciz "0====================0====================0====================0====================0\n"
rules: .asciz "The rules are simple:\nPress the button when the LED light is lit up to progress through the levels.\nBUT BE CAREFUL! If you press the button when the LED is off, you will be set back down to the previous level!\nOnce you complete the top green LED level, YOU WIN!!!\n"
ready: .asciz "Press the button when you are ready to play!\n"
good_luck: .asciz "GOOD LUCK!"
winner: .asciz "YOU WIN!"
play_again: .asciz "Press the button to play again!\n"

.equ OUTPUT, 1
.equ LOW, 0
.equ HIGH, 1
.equ BUTTON, 0
.text

.global main
main:
	push {lr}
	bl wiringPiSetup 	// wiringPiSetup(); // initialize the wiringPi library
welcome:
	ldr r0, =title
	bl printf
	ldr r0, =design
	bl printf
	ldr r0, =rules
	bl printf
	ldr r0, =design
	bl printf
	ldr r0, =ready
	bl printf
are_you_ready_button:
	mov r0, #BUTTON		//storing button state in r0
	bl digitalRead		//read the button state
	cmp r0, #0		//compare to see if button is pressed
	bne are_you_ready_button// branch to are you ready if button no pressed
	ldr r0, =500
	bl delay
initializing:
	mov r5, #0		//r5 is going to be set to one. r5 is going to be one of our two "stalls" so that checking whether or not button is pressed can occur
	mov r6, #0		//r6 "stalls" the time even further
	mov r7, #0		//same function as r5 but for off
	mov r8, #0		//same function as r8 but for off
	mov r9, #1		//variable of what level you are on
	mov r10, #12
on:
	mov r7, #0		//remember the r7 is = to the variable of the off delay. We need to set this back to 0 so the off function can function correctly
	mov r8, #0		//r8 also needs to be set to 0 in order for the off function to work correctly
	mov r0, r9 		//the reason we set r0 to r9 is for simplicity. This way, all we have to do is to increment or decrease r9 by a factor of 1 to roll through different LEDS
	mov r1, #OUTPUT		//LED is now on (1)
	bl pinMode		//turn the light on

	mov r0, #BUTTON		//storing button state in r0
	bl digitalRead		//read the button state
	cmp r0, #0		//compare the state of the button to 0 (off)
	beq success		//if button is equal to 0  then call to keep success function to keep the light on

//the goal of this function and it's "brother" the button_pressed_off function, is to constantly check if the button is on by calling back to the on/off functions.
//with every loop it calls back to the on/off function to check to see if the light is on. It also stalls the light so it stays on 100 milliseconds at a time
button_pressed_on:
	cmp r5, #100		//comparing the loop tracker with r5 with #100. No particular reason for the #100. It just works out better this way

	ldrlt r0, =#100		//load register r0 with 100 ONLY if r5 is less than 100
	addlt r5, #1		//add if r5 < 100 with a factor of 1
	bllt delay		//call the delay function if r5 < 100
	addgt r6, #1		//add if r5 > 100 to 2nd loop counter r6 (r6 just stalls the light being on for a little while longer so the game isn't too hard)
	movgt r5, #0		// mov r5 back to zero if greater than r0
	cmp r6, r10		//compare r6 with the r10(speed) (Again this number was based on the number of loops that worked the best with how long the light stays on
	bgt off			//branch if greater than
	bne on			//branch if not equal
off:
	mov r5, #0		//we need to initialize r5 to 0 for the on function to work correctly once its called again
	mov r6, #0		//we need to initialize r6 to 0 for the off function to work correctly once its called again

	mov r0, r9		//remember that r9 stores which PIN we are at...
 	mov r1, #LOW		//low is just = to off.
	bl pinMode		//In this case we are just turning the light off

	mov r0, #BUTTON		//storing button state in r0
	bl digitalRead		//read the button state
	cmp r0, #0		//compare the state of the button to 0 (off)
	beq fail		//if button is equal to 0 then call the fail function

button_pressed_off:
	cmp r7, #100		//comparing the loop tracker with r5 with #100. No particular reason for the #100. It just works out better this way

	ldrlt r0, =#100		//load register r0 with 100 ONLY if r5 is less than 100
	addlt r7, #1		//add if r7 < 100 with a factor of 1
	bllt delay		//call the delay function if r7 < 100
	addgt r8, #1		//add if r7 > 100 to 2nd loop counter r8 (r8 just stalls the light being on for a little while longer so the game isn't too hard)
	movgt r7, #0		// mov r7 back to zero if greater than 0
	cmp r8, #10		//compare r8 with the #10 (Again this number was based on the number of loops that worked the best with how long the light stays on
	bge on			//branch if greater than
	bne off			//branch if not equal
success:
	mov r5, #0		//set r5 back to zero for functions to work correctly
	mov r6, #0		//same as the previous instruction
	mov r0, r9		//remember r9 stores which PIN we are at
	mov r1, #OUTPUT		//output = on
	bl pinMode		//turning the light on

	ldr r0, =500		//adding a delay in order to prevent the next level from starting right away
	bl delay		//delay function

	sub r10, #3		//subtracting r10 by 3 decreases the amount of time the LED is left on, therefore making it harder as one progresses

	cmp r9, #5		//there's 5 levels, so we compare the #5 with register 9(PIN location).
	addle r9, #1		//r9 is the PIN number which also indicates what level we are on. So if we are successful, we need to add the PIN by 1 to move to next LED
	blt on			//if r9 is less than 5 we need to call back the on function to move on to the next level
	bge set_off		//if it's greater than or equal that means we reached the last level (PIN 5) so we need to call set_off function
fail:
	//set the pin - 1 if the level is not equal to 1 else restart the program
	mov r0, r9		//remember r9 is PIN location
	mov r1, #LOW		//Low = off
	bl pinMode		//call to turn LED off

	ldr r0, =500		//this gives a delay time of it being off so that the level doesnt reset right away
	bl delay		//call the delay function

	cmp r10, #12		//remember that r10 is just the speed. But it's a fixed speed, we can't have being greater than 12
	addne r10, #3		//therefore if r10 isn't equal to 12 we need to add 3 to r10 back (based on the level difficulty factor)

	cmp r9, #1		//compare r9 with the #1
	subgt r9, #1		//subtract r9 with the #1 if its greater than one. The reason is there is that at PIN 0 is where the button is. if we lose we go down 1 only if > 1
	b on			//call on function to restart previous level over
//this function sets all of the lights off... only achieved if you win the game obviously
set_off:
	cmp r9, #6		//r9 is pin location. remember the success function added 1 to the number 5, which makes us at 6 at r9 now. There's no PIN at 6 so we need to change that
	subeq r9, #1		//subtract r9, #1 since we are at 6
	mov r0, r9		//mov to PIN number
	mov r1, #LOW		//set PIN number to off = low
	bl pinMode		//turn light off
	cmp r9, #1		//compare r9, #1
	subge r9, #1		//subtract r9 if r9 is greater than 1 (remember no LED that is less than one exists, button is at PIN 0)
	cmp r9, #0		//compare r9 with 0
	bne set_off		//if r9 is not equal to one then call back set_off function to keep turning every light off
again:
	mov r0, #0
	ldr r0, =design		//print the design again
	bl printf		//print
	ldr r0, =play_again	//0 to play_again
	bl printf		//printing
	bl are_you_ready_button	//call back to read the button
done:
	mov r0, #0		//return 0;
	pop {pc}
