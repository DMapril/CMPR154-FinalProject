INCLUDE Irvine32.inc



.data	;section for messages

getName BYTE "Hello, please enter your name: ", 0

;;;;START SECTION
menu BYTE "*** Syntax Errors ***", 3 DUP(0Ah)
	 BYTE "*** MAIN MENU ***", 2 DUP(0Ah)
	 BYTE "Please Select one of the following: ", 2 DUP(0Ah),09h
	 BYTE "1: Display my available credits", 0Ah, 09h
	 BYTE "2: Add credits to my account", 0Ah, 09h
	 BYTE "3: Play the guessing game", 0Ah, 09h
	 BYTE "4: Display my statistics", 0Ah, 09h
	 BYTE "5: To exit", 0Ah, 0



;;;;DISPLAYBALANCE
currentBalance BYTE "Your available balance is: $", 0



;;;;ADDCREDITS SECTION
depositCredits BYTE "Please enter the amount you would like to add: $", 0
errorMsg BYTE "Error: Maximum allowable credit is $20.00", 0Ah
		     BYTE "Please enter a different amount: $", 0



;;;;GUESSINGGAME SECTION
ggBanner BYTE "************* WELCOME TO THE GUESSING GAME ****************", 2 DUP(0Ah), 0
ggInsufficient BYTE "NOT ENOUGH CREDITS!", 0Ah, "1 ROUND = $1", 2 DUP(0Ah), 0
ggInputMsg BYTE "Please guess a number between 1 and 10: ", 0
ggInputError BYTE 0Ah, "Invalid input, must be an integer in range of 1 - 10", 0Ah, 0
ggWinnerMsg BYTE 2 DUP(0Ah), "CONGRATULATIONS, YOU HAVE WON...$2!", 0
ggLoserMsg BYTE 2 DUP(0Ah), "YOU LOSE! THANKS FOR THE MONEY!! BETTER LUCK NEXT TIME!!!", 0
ggAnswer BYTE 2 DUP(0Ah), "The correct number is... ", 0 
ggTryAgain BYTE 3 DUP(0Ah), "Would you like to try your luck again? (y/n) ", 0



;;;;DISPLAYSTATS SECTION



.data	;section for variables
digit BYTE ?			;Menu selection
balance DWORD 0			;Current balance
amount DWORD ?			;Deposit amount
ranNum DWORD ?			;Random number
ggInput DWORD ?			;User's guess
ggYesNo BYTE ?			;User response to y/n
ggPlayed DWORD 0		;Games played
ggCorrect DWORD 0		;Correct guesses
ggMiss DWORD 0			;Missed guesses
ggMoneyW DWORD 0		;Money won
ggMoneyL DWORD 0		;Money lost

MAX_CHARS = 15			;For easier modification of pName char allowance
pName BYTE MAX_CHARS + 1 DUP(?)	;Player Name (+1 '?' for null )



.code
main proc

mov edx, OFFSET getName
call WriteString

mov edx, OFFSET pName			;sets edx to starting addr. of pName
mov ecx, MAX_CHARS				;makes it so 15 chars are read 
call ReadString
call Clrscr



START:							
	mov edx, OFFSET menu
	call WriteString



CHOICE:							;User input for menu selection
	call ReadChar
	mov digit, al

	cmp digit, '1'	
	jz DISPLAYBALANCE	
	cmp digit, '2'
	jz ADDCREDITS
	cmp digit, '3'
	jz GUESSINGGAME
	cmp digit, '4'
	jz DISPLAYSTATS
	cmp digit, '5'
	jz EXITGAME

	jmp CHOICE



;;;;;;;;;;;;;;;;;;;;;;;
DISPLAYBALANCE:
	call Clrscr				

	mov edx, OFFSET currentBalance
	call WriteString
	mov eax, balance
	call WriteDec
	mov al, 0Ah					;Newline before waitmsg
	call WriteChar

	call WaitMsg
	call ClrScr
	jmp START
;;;;;;;;;;;;;;;;;;;;;;;;	
ADDCREDITS:
	MAX_AMOUNT = 20 
	call Clrscr
	
	mov edx, OFFSET depositCredits
	call WriteString

	CREDITCHECK:				    
		call ReadInt			;Alter this to use "ReadDec" instead
		jo INVALIDAMOUNT
		mov ecx, MAX_AMOUNT		;Can't have imme(MAX_AMOUNT) as destination in cmp conditional
		cmp ecx, eax		
		jc INVALIDAMOUNT
		add balance, eax
		mov eax, 0
	
	call Clrscr
	jmp START

	INVALIDAMOUNT:
		call Clrscr
		mov edx, OFFSET errorMsg
		call WriteString
		jmp CREDITCHECK

;;;;;;;;;;;;;;;;;;;;;;;;
GUESSINGGAME:
	credit = 1		;Price of game
	call Clrscr


	CHECKBALANCE:
		mov eax, balance
		cmp eax, credit
		jc NOENTRY


	GENERATENUMBER:
		mov eax,10
		call Randomize			;re-seed (Without this instruction here the first number generated is always 5.)
		call RandomRange
		inc eax
		mov ranNum, eax


	GUESS: 
		mov edx, OFFSET ggBanner
		call WriteString
		mov edx, OFFSET ggInputMsg
		call WriteString
		jmp CHECKGUESS


	CHECKGUESS:					;ISSUE: valid digit followed by random input is seen as valid i.e., "4+3", "4a" (Forgot solution)
		call ReadInt			;Might be able to optimize by using "ReadDec" instead 
		jo INVALIDGUESS			;Overflow flag set if input is a character
		test eax, eax			;Testing if input is 0 (could use "cmp eax, 0" too)
		jz INVALIDGUESS
		mov ggInput, eax
		mov eax, 10
		cmp eax, ggInput
		jc INVALIDGUESS


	inc ggPlayed
	ANSWER:
		mov edx, OFFSET ggAnswer
		call WriteString
		mov eax, 2000
		call Delay
		mov eax, ranNum
		call WriteDec
		mov al, '!'
		call WriteChar
		mov eax, ggInput		;Beginning of valid input checks(Can split from Answer)
		cmp eax, ranNum
		jz WINNER
		jmp LOSER
	

	INVALIDGUESS:
		mov edx, OFFSET ggInputError
		call WriteString
		call WaitMsg
		call Clrscr
		jmp GUESS


	WINNER:
		mov edx, OFFSET ggWinnerMsg
		call WriteString
		add balance, credit
		add ggMoneyW, 2			;Make it not a magic constant?
		inc ggCorrect
		jmp TRYAGAIN


	LOSER:
		mov edx, OFFSET ggLoserMsg
		call WriteString
		sub balance, credit
		add ggMoneyL, credit	
		inc ggMiss
		jmp TRYAGAIN			;Not necessary


	TRYAGAIN:
		mov edx, OFFSET ggTryAgain
		call WriteString
		jmp CHECKCHAR


	CHECKCHAR:
		call ReadChar
		mov ggYesNo, al
		cmp ggYesNo, 'y'
		jz GUESSINGGAME
		cmp ggYesNo, 'n'
		jnz CHECKCHAR


	call Clrscr
	jmp START


	NOENTRY:
		mov edx, OFFSET ggInsufficient
		call WriteString
		call WaitMsg
		call Clrscr
		jmp START
;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAYSTATS:
	call Clrscr


	call WaitMsg
	call Clrscr
	jmp START
;;;;;;;;;;;;;;;;;;;;;;;;



EXITGAME:

exit
main endp
end main