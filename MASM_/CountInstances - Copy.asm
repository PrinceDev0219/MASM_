Title   Project 5           (proj5_butlejam.asm)

; Description: Create 200 random numbers between 15 and 50, display with 20 columns. calculate the median, then sort them ascending and display in the same matrix.
; lastly show the instance summations.


INCLUDE Irvine32.inc

.data

helloMessage				BYTE	  "Project 5: creating, sorting, calculating median integers from 200 random numbers. James Butler.", 0
explanation					BYTE   "show random numbers between 15 and 50, then show the median and sorted list in descending order", 0
medianNum					BYTE	  "The median number is: ",0
spaces						BYTE	  "  ", 0
goodbye						BYTE	  "End of randomizing matrices", 0
countofnumbers				BYTE	  "List of count numbers", 0
beforeSort					BYTE	  "Unsorted matrix: ", 0
afterSort					BYTE	  "Acsending sorted Matrix: ", 0
request						DWORD  ?
temp						DWORD  ?
counter						DWORD  ?
;constants
COLUMNS			=		 20
LO				=		 15
HI				=		 50
MAX_SIZE		=		 200
COUNTLISTSIZE	=		 35
;Arrays
list						DWORD MAX_SIZE DUP(?)  ;
countArray					DWORD COUNTLISTSIZE DUP(?) ; new array to store counts of each number



.code
 main PROC
 
	call introduction
	push OFFSET request
	call setUpArray
	call Randomize			
	push OFFSET list
	push request
	call fillArray
	;---------------------
	

	mov edx,offset countofnumbers
	call WriteString

    
	;---------------------
	mov  edx, OFFSET beforeSort
	call WriteString
	call CrLf
	push OFFSET list
	push request
	call displayList
	;///////////////////////
	push OFFSET list
	push request
	call makecountArray
	;///////////////////////
	push OFFSET list
	push request
	call sortList
	call CrLf
	push OFFSET list
	push request
	call displayMedian
	call CrLf
	mov  edx, OFFSET afterSort
	call WriteString
	call CrLf
	push OFFSET list
	push request
	call displayList
	push OFFSET list
	push request
;	call sortList1  ; Neeed the list of counted instance here
	call CrLf
	push OFFSET list
	push request
	call displayList
	;---------------------------
	call CrLf
	call CrLf
	mov edx,offset countofnumbers
	call WriteString
	call CrLf
	push OFFSET countArray
	push COUNTLISTSIZE
	call displayList

	;call displayInst
	;----------------------------
	call farewell
	exit
main ENDP

introduction PROC
	; Intro process to user
	call	CrLf
	mov		edx, OFFSET helloMessage
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET explanation
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP

setUpArray PROC
		push	ebp
		mov		ebp, esp
		mov		ebx, [ebp + 8] 
		mov		eax, MAX_SIZE
		mov		[ebx], eax	
		pop		ebp
	ret 4 
setUpArray ENDP

;fill array 

fillArray PROC
	push ebp
	mov  ebp, esp
	mov  esi, [ebp + 12]  
	mov	 ecx, [ebp + 8] 
	

	fillArrLoop:
		mov		eax, HI
		sub		eax, LO
		inc		eax
		call	RandomRange
		add		eax, LO
		mov		[esi], eax  ; random number in array
		add		esi, 4		; next element
		loop	fillArrLoop

	pop  ebp
	ret  8
fillArray ENDP

;list out min values per row

displayList PROC
	push ebp
	mov  ebp, esp
	mov	 ebx, 0			  
	mov  esi, [ebp + 12]  
	mov	 ecx, [ebp + 8]   
	displayLoop:
		mov		eax, [esi]  ;current element
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		inc		ebx
		cmp		ebx, COLUMNS
		jl		skipCarry
		call	CrLf
		mov		ebx,0
		skipCarry:
		add		esi, 4		;next element in sequence
		loop	displayLoop
	endDisplayLoop:
		pop		ebp
		ret		8
displayList ENDP






;print out values of our created list
sortList PROC
	push ebp
	mov  ebp, esp
	mov  esi, [ebp + 12]			
	mov	 ecx, [ebp + 8]				
	dec	 ecx
	outerLoop:
		mov		eax, [esi]			; get current element
		mov		edx, esi
		push	ecx					; save outer loop 
		innerLoop:
			mov		ebx, [esi+4]
			mov		eax, [edx]
			cmp		eax, ebx
			jle		skipSwitch
			add		esi, 4
			push	esi
			push	edx
			push	ecx
			call	exchange
			sub		esi, 4
			skipSwitch:
			add		esi,4

			loop	innerLoop
			skippit:
		pop		ecx 			; restore outer loop counter
		mov		esi, edx		

		add		esi, 4			; next element
		loop	outerLoop
	endDisplayLoop:
		pop		ebp
		ret		8
sortList ENDP

makecountArray PROC
	push ecx
	mov ecx, COUNTLISTSIZE ; initialize countArray to zeroes
	push esi
    mov esi, OFFSET countArray ; point to first element of count array
    initCountArrayLoop:
        mov dword ptr [esi], 0 ; set current element to 0
        add esi, TYPE countArray
    loop initCountArrayLoop 
	pop esi
	pop ecx

	push ebp
	mov  ebp, esp
	mov  esi, [ebp + 12]			
	mov	 ecx, [ebp + 8]
	push esi
	push ecx
	dec ecx
	mov		eax, LO
	countloop:
	mov		edx, esi
	push	ecx					; save outer loop 
	subcountloop:
		mov	ebx, [esi]
		cmp eax,ebx
		Jnz jmpSwitch
		inc [countArray + eax * 4 - LO * 4]
		jmpSwitch:
		add		esi,4
		loop	subcountloop
		inc eax
	pop		ecx 			; restore outer loop counter
	mov		esi, edx		

	add		esi, 4			; next element
	loop	countloop
	endDisplayLoop:
		pop ecx
		pop esi
		pop		ebp
		ret		8
makecountArray ENDP

;print out values start here
exchange PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		eax, [ebp + 16]	 ;first number			
	mov		ebx, [ebp + 12]	 ;second number			
	mov		edx, eax
	sub		edx, ebx					

	
	mov		esi, ebx
	mov		ecx, [ebx]
	mov		eax, [eax]
	mov		[esi], eax  ; put eax in array
	add		esi, edx
	mov		[esi], ecx

	popad
	pop		ebp
	ret		12
exchange ENDP


;display proc starts here
displayMedian PROC
	push ebp
	mov  ebp, esp
	mov  esi, [ebp + 12]  
	mov	 eax, [ebp + 8]   
	mov  edx, 0
	mov	 ebx, 2
	div	 ebx
	mov	 ecx, eax

	medianLoop:
	add		esi, 4
	loop	medianLoop
	mov		eax, [esi-4]
	add		eax, [esi]
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	mov		edx, OFFSET medianNum
	call	WriteString
	call	WriteDec
	call	CrLf
	jmp		endDisplayMedian

	endDisplayMedian:

	pop  ebp
	ret  8
displayMedian ENDP


	


;say countofnumbers
fncountofnumbers PROC

	call	CrLf
	mov		edx, OFFSET countofnumbers
	call	WriteString
	call	CrLf
	call	CrLf
	exit
fncountofnumbers ENDP




; say goodbye
farewell PROC

	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	call	CrLf
	exit
farewell ENDP
END main
end