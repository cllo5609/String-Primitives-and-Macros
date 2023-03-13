; Author: Clinton Lohr
; Last Modified: 12/04/2021	
; Description: This program takes in ten signed integers from the user. Values are stored
;	as strings. Each input is validated to make sure it fits into a 32-bit register and is a signed integer.
;	The integer is then converted from string form into decimal form. Once in decimal form the sum,
;	and average are calculated and stored in memory. Finally, the stored integers are converted
;	back into ascii characters and the list of entered integers, the sum, and the average are
;	displayed. The program uses Macros to gather input and display input. Conversions are done using
;	string primitives.

INCLUDE Irvine32.inc

; Constant values representing the upper limit for user input integers 
; and size of array for storing user input
	UPPERLIMIT = 2147483648
	ARRAYSIZE  = 10

;------------------------------------------------------------
; Name:	mGetString
; 
; Description: Takes as arguments a prompt string, a memory address to store a user input,
;				and the size of the storage array. Uses ReadString to get user input.
;
; Preconditions: Storage array defined in data segment
;
; Receives: 
;			[EBP + 16]		= string prompt	= dispPrompt
;			[EBP + 12]		= memory address for array = buffer
;			[EBP + 8]		= size of array = buffSize
; Returns:	value in string form, size of input
;------------------------------------------------------------
mGetString		MACRO dispPrompt, buffer, buffSize
	PUSH	EDX
	PUSH	ECX

	MOV		EDX, dispPrompt
	CALL	WriteString

	MOV		EDX, buffer
	MOV		ECX, buffSize
	CALL	ReadString
	MOV		strArrLen, EAX
	POP		ECX
	POP		EDX
ENDM

;------------------------------------------------------------
; Name:	mDisplayString
; 
; Description: Takes a string input and uses WriteString to display the input
;
; Preconditions: String defined in data segment
;
; Receives: stringInput = a string 
;
; Returns: N/A
;------------------------------------------------------------
mDisplayString	MACRO stringInput
	PUSH	EDX
	MOV		EDX, stringInput
	CALL	WriteString
	POP		EDX
ENDM

.data
	introOne		BYTE	"	Integer Calculations with Low Level I/O Procedures		", 0
	introTwo		BYTE	"By Clinton Lohr", 13, 10, 13, 10, 0
	instrOne		BYTE	"Please enter ten signed decimal integers", 13, 10, 0
	instrTwo		BYTE	"Integers must fit inside a 32-bit register to be valid", 13, 10, 0
	instrThree		BYTE	"Once all integers are entered, the following will be displayed:", 13, 10,
							"-The list of integers", 13, 10,
							"-The sum of the integers", 13, 10,
							"-The average of the integers", 13, 10, 13, 10, 0
	promptOne		BYTE	"Please enter a signed integer: ", 0
	errorStr		BYTE	"INVALID INPUT: Your input was either too large or not a signed integer", 13, 10, 0
	listDisplay		BYTE	"Here are the numbers you entered:", 13, 10, 0
	commaStr		BYTE	", ", 0
	sumDisplay		BYTE	"The sum of the numbers is: ", 0
	avgDisplay		BYTE	"The truncated average of the numbers is: ", 0
	goodbye			BYTE	13, 10, 13, 10, "Thank you for using the Integer Calculations program! See you next time!", 13, 10, 0
	numArray		SDWORD	ARRAYSIZE DUP(?)			; Signed double word, uninitialized, array stores user entered values as integers
	stringArray		SBYTE	14 DUP(?)					; Signed byte, uninitialized, array stores ascii numbers representing one integer
	reverseArray	SBYTE	14 DUP(?)					; Signed byte, uninitialized, array stores ascii numbers representing one integer reversed
	userVal			SBYTE	14 DUP(?)					; Signed byte, uninitialized, array stores ascii numbers representing user entered value
	strArrLen		SDWORD	?
	checkVal		DWORD	?							; Unigned byte, uninitialized, stores boolean value for number validation
	numInt			DWORD	?							; Unigned byte, uninitialized, stores user entered number as integer
	sumNums			SDWORD	?							; Unigned byte, uninitialized, stores sum of user entered number as integer
	avgNums			SDWORD  ?							; Unigned byte, uninitialized, stores average of user entered number as integer

.code

;------------------------------------------------------------
; Name:	main
; 
; Description: Consists of procedure calls which frame the program. Contains two loops to call the RealVal and WriteVal procedures multiple times.
;
; Preconditions: All data variables defined in .data
;
; Postconditions: N/A
;
; Receives: N/A
;
; Returns: N/A
;------------------------------------------------------------
main PROC

	; Introduction: pushes global data variable strings to the stack and calls the introduction procedure.
	PUSH	OFFSET introOne
	PUSH	OFFSET introTwo
	PUSH	OFFSET instrOne
	PUSH	OFFSET instrTwo
	PUSH	OFFSET instrThree
	CALL	Introduction					; Introduces and displays the program title, author, program description, and instrucitons

	; Prepares counter and storage array for the read loop calling the procedure ReadVal
	MOV		ECX, LENGTHOF numArray
	MOV		ESI,  OFFSET numArray

_readLoop:
	; Loop used to get values from the user by calling the ReadVal procedure. Loop count is equal to the size of the storage array.
	; Increments ESI upon each loop to move pointer to next memory location in storage array
	PUSH	OFFSET errorStr
	PUSH	OFFSET numInt
	PUSH	ESI								; Represents the current memory location in the storage array. Increments memory location with each loop
	PUSH	OFFSET checkVal
	PUSH	OFFSET strArrLen
	PUSH	OFFSET promptOne
	PUSH	OFFSET userVal
	PUSH	SIZEOF userVal
	CALL	ReadVal
	
	; Increment pointer in storage array by four bytes then loop
	ADD		ESI, 4
	LOOP	_readLoop

	; CALCULATE SUM: Pushes the storage array containing user input as integers to calculate the sum.
	; Stores sum in a unique data variable
	PUSH	OFFSET		numArray
	PUSH	LENGTHOF	numArray
	PUSH	OFFSET		sumNums
	CALL	CalculateSum


	; CALCULATE AVERAGE: Pushes the data variable holding the sum and array length to calculate the average.
	; Stores average in a unique data variable
	PUSH	OFFSET		numArray
	PUSH	LENGTHOF	numArray
	PUSH	OFFSET		sumNums
	PUSH	OFFSET		avgNums
	CALL	CalculateAvg
	CALL	Crlf

	; Displays the title for the list display by calling the mDisplayString macro
	MOV		EDX, OFFSET listDisplay
	mDisplayString EDX

	; Prepares counter and storage array for the write loop calling the procedure WriteVal
	MOV		EAX, OFFSET numArray
	MOV		ECX, LENGTHOF numArray

_writeLoop:
	; Loop used to display each value in the list of entered values. Loop count is equal to the size of the number array.
	; Increments EAX upon each loop to move pointer to next memory location in storage array
	PUSH	OFFSET reverseArray
	MOV		ESI, [EAX]
	PUSH	ESI								; Value stored at current memory location in num array
	PUSH	OFFSET stringArray
	PUSH	SIZEOF stringArray
	CALL	WriteVal

	; Increments the pointer to point to the next position in memory of the number array
	ADD		EAX, 4
	CMP		ECX, 1							; Checks if a comma should be added number display
	JE		_contWriteLoop
	MOV		EDX, OFFSET commaStr
	mDisplayString EDX

_contWriteLoop:
	LOOP	_writeLoop
	CALL	Crlf
	CALL	Crlf

	; Calls the mDisplayString macro to display the type for the sum
	MOV		EDX, OFFSET sumDisplay
	mDisplayString EDX

	; Pushes the sum of user entered numbers to be displayed
	PUSH	OFFSET reverseArray
	MOV		ESI, sumNums
	PUSH	ESI								; Value stored in the sumNums data variable
	PUSH	OFFSET stringArray
	PUSH	SIZEOF stringArray
	CALL	WriteVal
	CALL	Crlf
	CALL	Crlf
	
	; Calls the mDisplayString macro to display the type for the average
	MOV		EDX, OFFSET avgDisplay
	mDisplayString EDX

	; Pushes the average of user entered numbers to be displayed
	PUSH	OFFSET reverseArray
	MOV		ESI, avgNums
	PUSH	ESI								; Value stored in the avgNums data variable
	PUSH	OFFSET stringArray
	PUSH	SIZEOF stringArray
	CALL	WriteVal


	; Calls the farewell procedure to display a goodbye message
	PUSH		OFFSET goodbye
	CALL		Farewell
	Invoke ExitProcess,0	; exit to operating system
main ENDP

;------------------------------------------------------------
; Name:	Introduction
; 
; Description: Uses the mDisplayString macro to write the introduction for the program.
;	This includes the title, author, and description of the program and program instructions
;
; Preconditions: String literals defined in data segment
;
; Postconditions: Introductions strings displayed 
;
; Receives: 
;		[EBP + 24]		= program title string
;		[EBP + 20]		= author string
;		[EBP + 16]		= instrOne string
;		[EBP + 12]		= instrTwo integers
;		[EBP + 8]		= instrThree string
;
; Returns: N/A
;------------------------------------------------------------
Introduction	PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	
	; Series of calls to mDisiplayString Macro to print header and instructions
	MOV		EDX, [EBP + 24]			; title
	mDisplayString EDX			

	MOV		EDX, [EBP + 20]			; author
	mDisplayString EDX

	MOV		EDX, [EBP + 16]			; instrOne
	mDisplayString EDX

	MOV		EDX, [EBP + 12]			; instrTwo
	mDisplayString EDX

	MOV		EDX, [EBP + 8]			; instrThree
	mDisplayString EDX

	POP		EDX
	POP		EBP

	ret		20
Introduction	ENDP

;------------------------------------------------------------
; Name:	ReadVal
; 
; Description: Uses the mGetString Macro to get input from the user and store integer value as a string.
;	Subprocedures are called to validate the input, convert the input from ascii characters to a deciaml
;	value. If user input is invalid an error message is displayed and the user is prompted to re-enter input.
;
; Preconditions: storage arrays and strings defined in data segment
;
; Postconditions: user input is converted from ascii to decimal representation. numArray modified to hold integer.
;
; Receives: 
;			errorStr		= error message for invalid input
;			numInt			= storage for decimal value of input
;			ESI				= input value in string form					
;			checkVal		= boolean value to check input validity
;			strArrLen		= length of string representation of value
;			promptOne		= string to prompt user for input
;			userVal			= user value in form of string
;			SIZEOF userVal	= size of stirng input
;			
;
;
; Returns: user input in decimal form
;------------------------------------------------------------
ReadVal			PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX

_goAgain:
	; Code label reprompt the user for input if the input was invalid

	; Calls the mGetString macro to get user input. Sends display prompt, storage data variable, and size of storage variable
	mGetString	[EBP + 16], [EBP + 12], [EBP + 8]	

	; VALIDATE INPUT: Calls the Validate input procedure to validate user entered value
	PUSH	[EBP + 24]					; check Value
	PUSH	[EBP + 20]					; input length
	PUSH	[EBP + 12]					; user input
	PUSH	[EBP + 8]					; size of array
	CALL	ValidateInput

	; Checks the boolean value stored as a data variable, set in ValidateInput procedure. 
	; 1 = Invalid, 0 = Valid. Displays error message if invalid
	MOV		EAX, [EBP + 24]
	MOV		EBX, [EAX]
	CMP		EBX, 1
	JE		_displayError

	; CONVERT STRING TO INTEGER: Calls StringToInt procedure to convert user entered value form string to integer.
	PUSH	[EBP + 32]					; num for string to int
	PUSH	[EBP + 28]					; num Array
	PUSH	[EBP + 24]					; check Value
	PUSH	[EBP + 20]					; input length
	PUSH	[EBP + 12]					; user input
	PUSH	[EBP + 8]					; size of array
	CALL	StringToInt

	; Checks the boolean value stored as a data variable, set in StringToInt procedure. 
	; 1 = Invalid, 0 = Valid. Displays error message if invalid
	MOV		EAX, [EBP + 24]
	MOV		EBX, [EAX]
	CMP		EBX, 1
	JE		_displayError
	JMP		_finish						; User entered value was valid


_displayError:
	; Uses MDisplayString macro to display an error message if input was invaid. Reprompts user for input
	MOV		EDX, [EBP + 36]
	mDisplayString EDX
	JMP		_goAgain

_finish:								; Input was valid, return to main
	POP		EDX
	POP		EBX
	POP		EAX
	POP		EBP
	ret		32
ReadVal ENDP

;------------------------------------------------------------
; Name:	ValidateInput
; 
; Description: Subprocedure of ReadVal used to check whether the user entered a signed integer.
;	Reads SDWORD string by string to validate each byte.
;
; Preconditions: User input gathered from ReadVal
;
; Postconditions: data variable checkVal modified to represent validity of input (1 = invalid, 0 = valid)
;
; Receives: 
;		[EBP + 24]	= check Value boolean
;		[EBP + 20]	= length of input string
;		[EBP + 12]	= user input stored in data variable
;		[EBP + 8]	= size of array holding num values
;
; Returns: Boolean value modified to show validity of input
;------------------------------------------------------------
ValidateInput	PROC
	
	PUSH	EBP
	MOV		EBP, ESP

	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	
	
	; Sets the validity check data variable to invalid
	MOV		EAX, 1
	MOV		EDI, [EBP + 20]
	STOSD 

	XOR		EAX, EAX
	MOV		ESI, [EBP + 12]				; user input
	MOV		EBX, [EBP + 16]				; string length
	MOV		ECX, [EBX]					; length of user input

	; Compares length of user input ECX to zero to check if user entered a value
	CMP		ECX, 0
	JE		_endCheck

	CLD									; Clear direction flag, increment pointer
_loadChar:
	; Code label used to loop through bytes in the SDWORD holding user input
	; Loads first byte of SDWORD holding user input
	LODSB

	; Checks if byte is a (+)
	CMP		AL, 43
	JE		_sizeCheck

	; Checks if byte is a (-)
	CMP		AL, 45
	JE		_sizeCheck

_rangeCheck:
	; Checks if character is within range. Ends procedure if not in range
	CMP		AL, 48
	JL		_endCheck

	CMP		AL, 57
	JG		_endCheck

_loopChar:
	LOOP	_loadChar

	; Sets boolean data variable to 0. User input was valid. Stores integer in EDI
	MOV		EAX, 0
	MOV		EDI, [EBP + 20]
	STOSB
	JMP		_endCheck

_sizeCheck:
	; Checks if user only entered a + or - as input
	MOV		EDX, [EBX]
	CMP		EDX, 1
	JE		_endCheck

	; Checks if a + or - sign was entered anywhere besides the start of the integer
	CMP		ECX, EDX
	JNE		_endCheck
	JMP		_loopChar

_endCheck:
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP

	ret		16

ValidateInput	ENDP

;------------------------------------------------------------
; Name:	StringToInt
; 
; Description: Subprocedure called by ReadVal which uses string primitives to convert user input strings to 
;	decimal values. Checks that the user input fits into a 32-bit register. Uses local variables numVal to 
;	store the divisor in conversion and numStore to store loaded ascii character.
;
; Preconditions: User input has been gathered and validated to be a signed integer
;
; Postconditions: Decimal value converted and stored in number store array. Boolean check
;	modified to show validity of user input.
;
; Receives:
;		[EBP + 24]	= Reference to storage array for converted number
;		[EBP + 20]	= CheckBool boolean value data variable
;		[EBP + 16]	= Length of user input in form of ascii characters
;		[EBP + 12]	= Reference to user input value holding string input
;
; Returns: User input converted from ascii to decimal representation
;------------------------------------------------------------
StringToInt		PROC
	LOCAL	numVal:SDWORD, numStore:sbyte

	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	MOV		ESI, [EBP + 12]			; USER NUMBER
	MOV		EDI, [EBP + 24]			; NUMBER ARRAY
	MOV		EBX, [EBP + 16]			; INPUT LENGTH
	MOV		ECX, [EBX]				
	MOV		numVal, 0				; Initialize numVal to 0

	CLD
_strLoop:
	; Loads first byte of user entered value
	LODSB

	; Checks if user entered a + sign, disregards byte if true
	CMP		AL, 43
	je		_loopChar

	; Checks if user entered a negative integer
	CMP		AL, 45
	JE		_loopChar

	; Starts conversion from string character to integer
	SUB		AL, 48					; Subtract 48 to get integer value of character
	MOV		numStore, AL

	; Divides divisor by 10, stores quotient in numVal
	MOV		EAX, numVal
	MOV		EBX, 10
	MUL		EBX 
	JO		_overFlow				; Jumps if result exceeded 32-bit register
	MOV		numVal, EAX				; Store quotient
	MOVZX	EAX, numStore			; resizes numStore to fit into 32-bit register
	ADD		numVal, EAX
	JC		_overFlow				; Jumps if input exceeds 32-bit register
		
_loopChar:
	; Loops to get next byte
	LOOP	_strLoop

	; Checks if the first byte was a '-', indicating a negative value
	MOV		ESI, [EBP + 12]
	LODSB
	CMP		AL, 45
	JE		_twosComp				; Perform Two's complement conversion if value is negative
	CMP		numVal, UPPERLIMIT		; Check if value overflows register comparing it to max int for 32bit register
	JAE		_overFlow
	MOV		EAX, numVal				; Stores value into user number array
	STOSD
	JMP		_endIt
	
_twosComp:
	; Performs conversion to represent negative value in Two's complement form
	MOV		EAX, numVal
	CMP		EAX, UPPERLIMIT			; Check if value overflows register comparing it to max int for 32bit register
	JA		_overFlow	
	CMP		EAX, UPPERLIMIT
	JE		_edgeCase				; Checks the edge case where value entered was -2147483648

	; negates the positive form of the value for storage
	MOV		EBX, -1
	IMUL	EBX						
	JO		_overFlow
	STOSD
	JMP		_endit

_edgeCase:
	; negates the positive form if the value entered was -2147483648 (had to hard code due to bug in display)
	MOV		EBX, -1
	IMUL	EBX
	STOSD
	JMP		_endIt

_overFlow:
	; Runs if the user entered value overflows a 32-bit register. Sets validity boolean to 1 (invalid)
	MOV		EAX, 1
	MOV		EDI, [EBP + 20]
	STOSB
		
_endIt:
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		24

StringToInt		ENDP

;------------------------------------------------------------
; Name:	CalculateSum
; 
; Description: Takes the decimal values stored in numArray and sums them.
;
; Preconditions: Values validated and converted into decimal form.
;
; Postconditions: sum of integers are stored to sumNums data variable
;
; Receives: 
;			[EBP + 16] = numArray			= reference to array storing decimal input of user
;			[EBP + 12] = LENGTHOF numArray	= length of numArray
;			[EBP + 8]  = sumNums			= data variable used to store the sum
;
; Returns: The sum of the user's input in decimal form stored in sumNums
;------------------------------------------------------------
CalculateSum	PROC
	LOCAL	total:SDWORD	

	PUSH	EAX
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI

	MOV		ESI, [EBP + 16]			; User Num Array
	MOV		EAX, [EBP + 12]			; Array length
	MOV		EDI, [EBP + 8]			;sum storage array
	MOV		ECX, EAX
	MOV		total, 0

_addLoop:
	; Loops through each value of the number array and adds the value to the total
	MOV		EAX, [ESI]
	MOV		EBX, -1					;start check for negative int
	IMUL	EBX
	JNS		_negInt					; jumps if value is negative for subtratction
	MOV		EAX, [ESI]
	ADD		total, EAX
	JMP		_contLoop

_negInt:
	; Subtracts from total if value is negative
	SUB		total, EAX

_contLoop:
	; Increments pointer to point to next value in number array
	ADD		ESI, 4
	LOOP	_addLoop

	; Moves the sum into a data variable for storage
	MOV		EAX, total
	MOV		[EDI], EAX

	POP		EDI
	POP		ESI
	POP		ECX
	POP		EAX

	RET		12
CalculateSum	ENDP

;------------------------------------------------------------
; Name:	CalculateAvg
; 
; Description: Uses the sum of user's input and divides it by the length of the numArray to get the average
;	of the user's input. Rounds the integer up or down depending on remainder value.
;
; Preconditions: Sum must be calculated by the CalculateSum procedure
;
; Postconditions: The average of the user's input is stored in the avgNums data variable
;
; Receives: 
;			[EBP + 16] = LENGTHOF numArray	= length of numArray
;			[EBP + 12] = sumNums			= reference to array storing sum
;			[EBP + 8]  = avgNums			= data variable used to store the average
;
; Returns: Average of user's input is stored in avgNums data variable
;------------------------------------------------------------
CalculateAvg	PROC
	LOCAL	storeAvg:SDWORD

	PUSH	EAX
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI

	MOV		EBX, [EBP + 16]			; USER ARRAY LENGTH
	MOV		ESI, [EBP + 12]			; SUM DATA VARIABLE
	MOV		EDI, [EBP + 8]			; AVG ARRAY
	
	; Checks if the sum is positive or negative
	MOV		EAX, [ESI]
	XOR		EDX, EDX
	MOV		EBX, -1
	IMUL	EBX
	JNS		_negSumDivide			; Jumps to code label if negative for signed division

_posSumDiv:
	; Called to perform diviosn of the sum by the count of entered numbers if sum is positive
	MOV		EAX, [ESI]
	MOV		EBX, [EBP + 16]
	XOR		EDX, EDX
	DIV		EBX
	MOV		storeAvg, EAX			; stores average in loval variable

	; Checks if value of float should be rounded up or down
	MOV		EAX, EDX
	MOV		EBX, 2
	MUL		EBX

	; If remainder x 2 is greater than divisor, round up
	MOV		EBX, [EBP + 16]
	CMP		EAX, EBX
	JAE		_posRoundUp
	MOV		EAX, storeAvg
	JMP		_endAvg

_posRoundUp:
	; incrments to next integer value
	MOV		EAX, storeAvg
	INC		EAX					; Increments the calculated average by one (rounding up)
	JMP		_endAvg

_negSumDivide:
	; Called to perform diviosn of the sum by the count of entered numbers if sum is positive
	MOV		EAX, [ESI]
	MOV		EBX, [EBP + 16]
	XOR		EDX, EDX
	CDQ							; Sign extends EAX into EDX:EAX
	idiv	EBX					; Divides the signed values in EAX by EBX (sum/count)

	; Checks if average should be rounded up
	MOV		storeAvg, EAX
	IMUL	EDX, -2				; Multiplies count by -2 to make remainder positive
	CMP		EDX, EBX			; Compares EDX to denominator, if EDX is greater than numCount, decimal value is greater than 0.5
	JG		_negRoundUp
	MOV		EAX, storeAvg
	JMP		_endAvg

_negRoundUp:
	MOV		EAX, storeAvg
	DEC		EAX					; Decrements the calculated average by one (rounding up)
	JMP		_endAvg

_endAvg:
	MOV		[EDI], EAX			; Stores calculated average into storage data variable

	POP		EDI
	POP		ESI
	POP		ECX
	POP		EAX

	RET		16

CalculateAvg	ENDP

;------------------------------------------------------------
; Name:	WriteVal
; 
; Description: Takes in a single decimal value and converts it to its ascii representation using string
;	primitives. Numbers are loaded in byte by byte, converted, and then stored into an array.
;	The array is then loaded byte by byte in reverse order and stored in another array to
;	place the ascii characters in correct order. The procedure then uses the mDisplayString macro to 
;	display the single. Uses local variables signBool indicate the sign of the value and dividend to
;	store the dividend for the conversion calculation.
;
; Preconditions: Values are in decimal form 
;
; Postconditions: stringArray and reverseArray are modified to hold the ascii characters that make up
;	the signed integer. 
;
; Receives: 
;			[EBP + 20]  = reverseArray			= Reference to array to hold reversed ascii characters
;			[EBP + 16]  = ESI					= value in decimal form
;			[EBP + 12]  = stringArray			= Reference to array to hold ascii characters 
;			[EBP + 8]	= LENGTHOF stringArray  = length of stringArray
;
; Returns:N/A
;------------------------------------------------------------
WriteVal		PROC
	LOCAL signBool:BYTE, dividend:SDWORD

	PUSH	EDI
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

	MOV		ESI, [EBP + 16]				; Decimal Value
	MOV		EDI, [EBP + 12]				; String Array
	MOV		signBool, 0					; Sets sign bool to 0 (positive)
	MOV		dividend, 0					
	MOV		ECX, 0						; Holds count of ascii characters

	; Checks if integer is equal to 2147483648. If True, check if negative or positive
	CMP		ESI, UPPERLIMIT
	JE		_edgeCaseSign
	CMP		ESI, 715827883				; Checks if Average is equal to 715827883. If True, check if negative or positive
	JE		_edgeCaseSign
	JMP		_startWrite

_edgeCaseSign:
	; Runs if integer is equal to -2147483648, sets signBool to 1 (negative) 
	MOV		signBool, 1
	MOV		dividend, ESI
	JMP		_intToString

_startWrite:
	; Checks if integer is 0, negative, or positive before converting
	; Check if integer is 0
	MOV		EAX, ESI
	CMP		EAX, 0
	JE		_startLoop

	; Check if integer is negative or positive by negating
	IMUL	EAX, -1
	JS		_startLoop				; jumps if integer is positive
	MOV		signBool, 1				; set signBool to 1 (negative)
	MOV		dividend, EAX
	JMP		_intToString

_startLoop:
	; Move integer to dividend for conversion
	MOV		dividend, ESI

_intToString:
	; initially divides integer, then divides quotient until quotient equals zero
	CLD
	MOV		EAX, dividend
	XOR		EDX, EDX
	MOV		EBX, 10
	DIV		EBX

	; Add 48 to remainder to give ASCII representation
	ADD		EDX, 48
	MOV		dividend, EAX
	MOV		EAX, EDX
	STOSB							; Store ASCII value in byte array
	INC		ECX						; Increment count of ascii characters
	MOV		EAX, dividend
	CMP		EAX, 0					; Checks if we have reached the end of the conversion
	JE		_checkSign				; Jumps to check if a negative sign needs to be added
	JMP		_intToString			; Continue to find next ascii character

_checkSign:
	; Checks signBool to see if a negative ascii character needs to be added
	CMP		signBool, 1
	JNE		_revString

	; Add negative ascii character to SDWORD
	MOV		EAX, 45
	STOSB
	INC		ECX						; Increment count for character length

_revString:
	; Sets up registers with a source array and destination array for reversing the string
	MOV		ESI, [EBP + 12]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP + 20]

_revLoop:
	; Reverses the ascii characters to correct position, moving bytes from string array to reverse array data arrays
	STD								; Set direction flag to decrement
	LODSB							; Load ESI from the end of array
	CLD								; Set direction flag to increment
	STOSB							; Store in EDI the decrementing character in ESI
	LOOP	_revLoop

	; Calls mDisplayString macro to write the converted value
	MOV		EDX, [EBP + 20]
	mDisplayString	EDX 

	; Clears the string array for the next value in number array
	XOR		EAX, EAX
	MOV		ECX, [EBP + 8]
	MOV		EDI, [EBP + 20]
	CLD
	REP		STOSB					; Repeats storage of Al (0)

	; Clears the reverse string array for the next value in number array
	XOR		EAX, EAX
	MOV		ECX, [EBP + 8]
	MOV		EDI, [EBP + 12]
	CLD
	REP		STOSB

	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		ESI
	POP		EDI
	RET		16
WriteVal ENDP

;------------------------------------------------------------
; Name:	Farewell
; 
; Description: Uses the mDisplayString macro to write a goodbye message to the user.
;
; Preconditions: String literal defined in data segment
;
; Postconditions: Goodbye message string displayed 
;
; Receives: 
;
;		[EBP + 8]		= goodbye string
;
; Returns: N/A
;------------------------------------------------------------
Farewell		PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX

	; Call to mDisplayString to disiplay goodbye message
	MOV		EDX, [EBP + 8]
	mDisplayString	EDX

	POP		EDX
	POP		EBP
	ret		4
Farewell		ENDP

END main
