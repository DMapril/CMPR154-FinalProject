INCLUDE Irvine32.inc


;Can split up the data sections for better isolation

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



;;;;ADDCREDITS SECTION
depositCredits BYTE "Please enter the amount you would like to add: $", 0
errorMsg BYTE "Error: Maximum allowable credit is $20.00", 0Ah
		     BYTE "Please enter a different amount: $", 0



;;;;GUESSINGGAME SECTION



;;;;DISPLAYSTATS SECTION



.data	;section for variables
digit BYTE ?			;Menu selection
balance DWORD 0			;Current balance
amount DWORD ?			;Deposit amount
MAX_CHARS = 15			;For easier modification of pName char allowance
pName BYTE MAX_CHARS + 1 DUP(?)	;Player Name (+1 '?' for null )



.code
main proc

mov edx, OFFSET getName
call WriteString

mov edx, OFFSET pName			;sets edx to starting addr. of pName
mov ecx, MAX_CHARS			;makes it so 15 chars are read 
call ReadString
call Clrscr



START:					
	mov edx, OFFSET menu
	call WriteString



CHOICE:					;User input for menu selection
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


	call WaitMsg
	call Clrscr
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
	call Clrscr


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
