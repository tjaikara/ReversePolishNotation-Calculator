;;; DO NOT MODIFY THIS SECTION
         .ORIG x4000
         .FILL HANDLE_NUM ; x4000
         .FILL HANDLE_OP  ; x4001
         .FILL HANDLE_END ; x4002
         .FILL MULT       ; x4003
         .FILL DIV        ; x4004
         .FILL PUSH       ; x4005
         .FILL POP        ; x4006
RESET    .FILL x3000
PRINTNUM .FILL x3001
         
;;; DO NOT MODIFY ABOVE THIS LINE

; ECE190 Machine Problem 3
; Spring 2012
; Name: Tony Jose Aikara	
; NetID: aikara2

   
; HANDLE_NUM will be called when a number is encountered in the Reverse
; Polish Notation expression.  The signed 2's complement number will be
; stored in R1.

HANDLE_NUM
        
		  ST R7,Save7        ;Stores the value of R7 in a memory location since it contain the return add of the caller

                  AND R0,R0,#0       ;Clearing the register
		  ADD R0,R0,R1       ;Loading the first number into R0 to push into stack
		  JSR PUSH           ;calling PUSH subrotuine to store the number in stack
        
		  LD R7,Save7        ;reloading R7 with the caller return add.
                  RET                ;return to the caller


Save7            .BLKW #1            ;blocked one memory location to save the R7 value
    
; HANDLE_OP will be called when an operator is encountered in the Reverse
; Polish Notation expression.  Stored in R1 will be a number which identifies
; which operator was encountered.  0 means +; 1 means -; 2 means *; 3 means /.

HANDLE_OP
        
		  ST R7,Save7_1      ;stores the value of R7 into a memory location since it contain the return add. of the caller
		
		  ADD R1,R1,#0     
		  BRz Addition       ;if zero, it means R1 contains zero. So branches to add to perform addition 
		 
                  LD R2,Negone       ;loading R2 with #-1
		  ADD R2,R2,R1       ;adding R2 and R1 and stores in R2
		  BRz Sub            ;if zero, R1 contains 1. So branches to sub to perform substraction
		 
                  LD R2,Negtwo       ;loading R2 with #-2
		  ADD R2,R2,R1       ;adding R2 and R1 and stores in R2
		  BRp Division       ;if positive, R1 contains 3. so branches to division. otherwise R1 contains
                                     ;2 for multiplication

                  JSR POP            ;jumps to the POP subrotuine to get the first value for multiplication
                  AND R1,R1,#0       ;clearing R1
		  ADD R1, R0, #0     ;POP success loading first value into R1
		  JSR POP            ;Jumps to POP to get the second value
                  AND R2,R2,#0
		  ADD R2,R0,#0       ;loading the second value into R2
                  JSR MULT           ;jumps to the MULT subrotuine
                  JSR PUSH           ;push the result into the stack
		  LD R7,Save7_1      ;reloading R7 with caller return address
		  RET                ;returning to the caller

Save7_1          .BLKW #1            ;block one memory location to Save the value in R7

Division         ST R7,Save7_2       ;Stores the return address of the caller function into a memory location 

                 JSR POP             ;jumps to POP to get the values  
		 ADD R2,R0,#0        ;POP was success, stores the value into R2 (which is the denomenator)
		 JSR POP             ;jumps to POP to get the second value
                 ADD R1,R0,#0        ;R1 geting the next value
                 JSR DIV             ;jumps to the division subrotuine
                 ADD R5,R5,#0        ;contains the success or failure of division
                 BRp Divbyzero       ;If positive that means denomenator is zero so brances to Divbyzero
                 JSR PUSH            ;Jump to the PUSH subrotuine
                
                 LD R7,Save7_2       ;reloading R7 with the caller's return address
		 RET                 ;returning to the caller


Addition         ST R7,Save7_2       ;storing the return address of caller function

                 JSR POP             ;jumps to the POP subrotuine to get the values for the addition 
                 AND R2,R2,#0
		 ADD R2,R0,R2        ;First POP was success. so loading the first value into R2
		 JSR POP             ;jumps to the subrotuine to get the next value
                 AND R3,R3,#0
		 ADD R3,R0,R3        ;POP was successful. Loading the new value into R3
		 AND R0,R0,#0        ;Clearing R0
		 ADD R0,R3,R2        ;Loading the sum into R0
		 JSR PUSH            ;calling push to load the sum into stack
                 LD R7,Save7_2       ;Loading R7 with the return add. of the caller
                 RET                 ;returns to the caller function

Sub              ST R7,Save7_2       ;Saves the return address of the caller function
      
                 JSR POP             ;jumps to the POP subrotuine to get the values for substraction
                 AND R3,R3,#0
		 ADD R3,R3,R0        ;First POP was success. so loading the first value into R3(which is the second operand).
		 NOT R3,R3           ;getting the negative of the R3 content
		 ADD R3,R3,#1
		 JSR POP             ;jumps to the subrotuine to get the next value from stack
		 AND R2,R2,#0
		 ADD R2,R2,R0        ;POP was successful. Loading the new value into R2(which is the first operand)
		 AND R0,R0,#0        ;clearing R0
		 ADD R0,R2,R3        ;loading the result into R0
                 JSR PUSH            ;jump to the push subrotuine to load the result into stack
		 LD R7,Save7_2       ;load R7 with the return add. of caller
		 RET                 ;returning to the caller function.


Divbyzero        LEA R0,ERR3         ;Load the memorry address of the error message 3 into R0
                 PUTS                ;Display the error message on screen
                 LEA R6,Stackbase    ;Resetting the stack pointer
                 ST R6,Pointer
                 LD R4,RESET         ;load R4 with the memory address of Reset function
                 JMP R4              ;jump to the reset location to reset the program

ERR3             .STRINGZ "ERR3: Division by zero.\n"

Save7_2          .BLKW #1            ;block one memory location to store the value of R7

Negone           .FILL xFFFF         ;negative value of #1
Negtwo           .FILL xFFFE         ;negative value of #2

; HANDLE_END will be called when the end of the Reverse Polish Notation
; expression is encountered.

HANDLE_END
        
		 ST R7,Save7         ;Saves the return address of the caller
		
		 JSR POP             ;jump to POP to pop the final value from stack
		 LD R6,Pointer       ;R6 is the stack pointer
		 LEA R1, StackBase   ;R1 loads with the value of the stack base
		 NOT R1,R1           ;taking the negative of R1
                 ADD R1,R1,#1
		 ADD R1,R1,R6        ;adding R1 and R6
                 BRn In_Expression   ;if above sum is negative there is some value left in the stack after
                                     ;we called the final result from the stack. It means that we inputed
                                     ;an incomplete representation
                 LD R6, PRINTNUM     ;If not negative, load R6 with the address of PRINTNUM
                 JSRR R6             ;jump to the PRINTNUM subrotuine to print the result on screen
		 LD R7,Save7         ;reloading the caller address to R7
                 RET                 ;return to the caller

In_Expression    LEA R0,ERR2         ;load R0 with the address of ERR2
                 PUTS                ;displays the error on monitor
                 LEA R6,StackBase    ;reseting the stack pointer
                 ST R6,Pointer
		 LD R4, RESET        ;loads R4 with the memory address of reset
		 JMP R4              ;jump to the reset location to reset the program

ERR2            .STRINGZ "ERR2: Incomplete expression.\n"		


;Resetpointer    .FILL StackBase      ;loading Resetpointer with the stackbase (doing it here is to keep it within the -256 to 255 range,
                                     ;otherwise for some JSR function it will be out of range)

; multiply R1*R2 and put the result in R0.

MULT
                 ST R7,Save_7        ;Storing the return address of the caller function in a memory location
		  
                 AND R0,R0,#0        ;clearing R0
		 ADD R1,R1,#0        ;
		 BRzp CheckZero      ;branches to checkzero if positive or zero
		 NOT R1,R1           ;otherwise taking the negative of the value in R1 to handle the negative numbers
		 ADD R1,R1,#1
		 NOT R2,R2           ;taking the negative of the value in R2
		 ADD R2,R2,#1
CheckZero        ADD R1,R1,#0        
		 BRz Answer          ;check for zero in R1. If its zero it branches to zero since the result is zero
MultLoop         ADD R0,R0,R2        ;starts the loop for multiplication
		 ADD R1,R1,#-1
		 BRp MultLoop
		 BRnzp Result        ;since result is already stored in R0 unconditionally branches to Result
Answer           ADD R0,R0,R1        ;when input R1 zero that value stores into R0
Result
          
		 LD R7, Save_7       ;reloading the return add. of caller funtion into R7

		 RET                 ;returning to the caller program 

        
; divide R1/R2 and put the result in R0.  on success, set R5 to 0. on fail, set R5
; to 1.

DIV  
                ST R3,save3          ;storing the register values in a memory location
                ST R4,save4          ;
             
             
                AND R3,R3,#0         ;Clearing the registers
                AND R4,R4,#0         ;
                AND R5,R5,#0         ;
             
             

                ADD R2,R2,#0         ;R2 conatins the denominator value
                BRz Den_Zero         ;If denominator zero, it branches to Den_Zero
                BRp invert           ;If R2 positive, it branches to invert to make R2 a negative value
                ADD R3,R3,#1         ;If R2 negative, R3 flag contains value #1
                BRnzp Loop           ;Since R2 is negative value it unconditionally branches to LOOP to keep its negative value
Invert          NOT R2,R2            ;geting negative of R2
                ADD R2,R2,#1
Loop            ADD R1,R1,#0         ;R1 contains the numearator value
                BRz Result_f         ;if numearator is zero the result will be zero, so it branches to Result_f
                BRp Loop1            ;If R1 positive, it loads to LOOP1 to start division loop
                ADD R5,R5,#1         ;If R1 negative, R5 flag will contain #1
                NOT R1,R1            ;Inverting R1 to make it positive
                ADD R1,R1,#1         ;
                BRnzp Loop1          ;Unconditionaly branches to Loop1 to start the division loop
Divloop         ADD R4,R4,#1         ;R4 is the counter, loading it with #1 to get the correct answer
Loop1           ADD R1,R1,R2         ;substracting R2 from R1
                BRzp Divloop         ;if it zero or positive branches to Divloop 
                ADD R3,R3,#0         ;Checking R3 falg to know whether denominator is negative or positive
                BRz Loop2            ;if denominator is positive it branches to Loop2 to check the sign of numearator
                NOT R4,R4            ;If demoninator is negative, inverting the result in R4
                ADD R4,R4,#1         ;
Loop2           ADD R5,R5, #0        ;Checking R5 flag to know whether numearator is negative or positive
                BRz Result_f         ;if numearator is positive it branches into Result_f
                NOT R4,R4            ;if numearator is negative inverting the result in R4
                ADD R4,R4,#1         ;
Result_f        AND R0,R0,#0         ;Clearing R0
                ADD R0,R0,R4         ;Loading the final Result into R0
                AND R5,R5,#0         ;Clearing R5
                ADD R5,R5,#0         ;Loading R5 with zero since the division is success
              
                LD R3,save3          ;Reloading the registers with their orginal value
                LD R4,save4          ;
   
                RET                  ;Returning to the caller program
        
 
Den_Zero        AND R5,R5,#0         ;Clearing R5
                ADD R5,R5,#1         ;Since denominator become zero is an undefined condition division fails and R5 loads with #1
             
                LD R3,save3          ;Restoring the register values
                LD R4,save4          ;
  
                RET                  ;Returning to the caller program
 

               
; push contents of R0 onto the stack.  on success, set R5 to 0. on fail, set R5 to 1.

PUSH    
                ST R1, Save_1        ;Store the register value into a memory location

		AND R1,R1,#0         ;Clearing R1

                LD R6, Pointer       ;Loading R6 with the address of stackbase
		LD R1, Top           ;Loading R1 with the address of stacktop
		NOT R1,R1            ;taking the negative value of R1
		ADD R1,R1,#1         ;
		ADD R1, R6,R1        ;adding R6 and R1 to check the overflow condition
		BRz Overflow         ;if zero stack is full, so overflow condition
		ADD R6, R6, #-1      ;If not decrementing the stack pointer
		ST R6, Pointer       ;storing the new value of stack ponter into the memory location specified by the label pointer
                STR R0, R6, #0       ;storing the value in R0 into the memory location specified by the decremented pointer
		BRnzp ExitC          ; unconditionally branches to ExitC

overflow        LEA R0,ERR4          ;Load the memorry address of the error message 4 into R0
                PUTS                 ;Display the error message on screen
                LEA R6,StackBase     ;Resetting the stack pointer
                ST R6,Pointer        ;
                LD R4,RESET          ;load R4 with the memory address of Reset function
                JMP R4               ;jump to the reset location to reset the program 

ExitC           LD R1, Save_1        ;reloading the register value

                RET                  ;Returning to the caller function

ERR4              .STRINGZ "ERR4: Stack overflow.\n"
        
; pop a number off of the stack and put it into R0.  on success, set R5 to 0.
; on fail, set R5 to 1.

POP
                ST R1, Save_1        ;Stores the R1 value into a memory location

		AND R1, R1, #0       ;clearing R1

                LD R6, Pointer       ;Loading R6 with the address of stackbase
		LEA R1, StackBase    ;Loading R1 with the address of stackbase
		NOT R1,R1            ;taking the negative value of R1
		ADD R1,R1,#1         ;
		ADD R1,R6,R1         ;adding R6 and R1 to check the underflow condition
		BRz Underflow        ;if zero stack is empty, so underflow condition
		LDR R0,R6,#0         ;If not, load R0 with the content of the memory location where the stack pointer is pointing 
		ADD R6,R6,#1         ;then increment the R6 by 1 pointing to the next location ahead
		ST R6, Pointer       ;store the new pointer value into the memory location specified by the label pointer
                LD R1, Save_1        ;Restore the register value		 

                RET                  ;return to the caller address

underflow       LEA R0,ERR1         ;Load the memorry address of the error message 1 into R0
                PUTS                ;Display the error message on screen
                LEA R4,RESET1       ;load R4 with the memory address of Reset function
                JMP R4              ;jump to the reset location to reset the program

ERR1             .STRINGZ "ERR1: Stack underflow.\n"
RESET1          .FILL x3000
        
StackTop        .FILL x0000          ;Top of the stack
Stack           .BLKW #30            ;Blocked #30 memory locations
StackBase       .FILL X0000          ;Stack Bottom
Top             .FILL StackTop       ;loadong the memory location labeled Top with the address of StackTop
Pointer         .FILL StackBase      ;Loading the memory location labeled Pointer with the address of Stackbase


Save3           .BLKW #1             ;Blocking one memory location to store the value of R3
Save4           .Blkw #1             ;Blocking one memory location to store the value of R4
save5           .BLKW #1             ;Blocking one memory location to store the value of R5
Save_7          .BLKW #1             ;Blocking one memory location to store the value of R7
Save_1          .BLKW #1             ;Blocking one memory location to store the value of R1

                .END

